# Backup code and DB data in production

CODE_ROOT_DIRECTORY = '/var/www/shf/current/'
DB_NAME = 'shf_project_production'
LOGS_ROOT_DIRECTORY = '/var/log'

# Errors
module ShfConditionError
  class BackupError < StandardError
  end

  class BackupConfigFilesBadFormatError < BackupError
  end

  class BackupCommandNotSuccessfulError < BackupError
  end
end

# @desc Abstract class for all backup classes.
#   backup_sources = the list of files or glob pattern of the files to be backed up
#   target_filename = filename of the backup (=target) created by backing
#   up the sources.
#
# Each Backup class must implement :backup(backup_target, sources) to do whatever
# it needs to do to create the backup
#
class AbstractBackupMaker

  attr :target_filename, :backup_sources

  # Set the backup target and the backup sources
  def initialize(target_filename: default_backup_filename,
                 backup_sources: default_sources)
    @target_filename = target_filename
    @backup_sources = backup_sources
  end


  # Do the backup. Default target is the target_filename; default sources = the backup sources)
  def backup(target: target_filename, sources: backup_sources)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  def default_backup_filename
    "backup-#{self.class.name}.tar"
  end


  def default_sources
    []
  end


  # Run the command using Open3 which allows us to capture the output and status
  # Raise an error unless the return status is success
  def shell_cmd(cmd)
    stdout_str, stderr_str, status = Open3.capture3(cmd)
    unless status&.success?
      raise(ShfConditionError::BackupCommandNotSuccessfulError, "Backup Command Failed: #{cmd}. return status: #{status}  Error: #{stderr_str}  Output: #{stdout_str}")
    end
  end

end


# Backup a list of files using tar. Create 1 resulting backup file
class FilesBackupMaker < AbstractBackupMaker

  # use tar to compress all sources into the file named by target
  # @return [String] - the name of the backup target created
  def backup(target: target_filename, sources: backup_sources)
    shell_cmd("tar -chzf #{target} #{sources.join(' ')}")
    target
  end

end


# Backup a list of code directories.  Create 1 resulting backup file 'current.tar'
class CodeBackupMaker < FilesBackupMaker

  DEFAULT_SOURCES = [CODE_ROOT_DIRECTORY]
  DEFAULT_BACKUP_FILEBASE = 'current.tar'


  def default_backup_filename
    DEFAULT_BACKUP_FILEBASE
  end


  def default_sources
    [CODE_ROOT_DIRECTORY]
  end
end


# Backup a list of databases. For each database: first use pg_dump to dump it,
# then add it to a gzip file.
# Create 1 resulting gzip file
#
class DBBackupMaker < AbstractBackupMaker

  DB_BACKUP_FILEBASE = 'db_backup.sql'

  # Backup all Postgres databases in sources, then gzip them into the target
  # @return [String] - filename of the backup target created
  def backup(target: target_filename, sources: backup_sources)

    shell_cmd("touch #{target}") # must ensure the file exists

    sources.each do |source|
      shell_cmd("pg_dump -d #{source} | gzip > #{target}")
    end
    target
  end


  def default_backup_filename
    DB_BACKUP_FILEBASE
  end


  def default_sources
    [DB_NAME]
  end
end


class Backup < ConditionResponder


  DEFAULT_BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'
  DEFAULT_CODE_BACKUPS_TO_KEEP = 4
  DEFAULT_DB_BACKUPS_TO_KEEP = 15
  DEFAULT_FILE_BACKUPS_TO_KEEP = 31

  TIMESTAMP_FMT = '%Y-%m-%d'

  # -------------


  def self.condition_response(condition, log)

    @slack_error_already_logged = false  # keep us from logging a Slack error every time it percolates up through rescue blocks

    validate_timing(get_timing(condition), [TIMING_EVERY_DAY], log)

    config = get_config(condition)
    backup_makers = create_backup_makers(config)

    # Backup each backup_maker to local storage
    backup_files = []
    backup_dir = backup_dir(config)

    backup_makers.each do |backup_maker|

      # Create a full file path that will be in the backup_directory,
      # and have the filename and extension provided by the backup_maker,
      # but with with date and '.gz' appended.
      backup_file = backup_target_fn(backup_dir, backup_maker[:backup_maker].target_filename)
      backup_files << backup_file

      begin
        log.record('info', "Backing up to: #{backup_file}")

        # this will use the default backup sources set when the backup_maker was created
        backup_maker[:backup_maker].backup(target: backup_file)

      rescue Slack::Notifier::APIError => slack_error
        # Halt the backup if we cannot write to Slack; log then raise the error
        log_slack_error(slack_error, 'while in the backup_makers.each loop', log)
        raise slack_error

      rescue => backup_error
        log_and_notify(backup_error, log)
        # Do NOT raise the error. This will let all other backup_maker.backups to run
        next
      end
    end


    # Copy backup files to S3
    log.record('info', 'Moving backup files to AWS S3')

    s3, bucket, bucket_folder = get_s3_objects(today_timestamp)

    backup_files.each do |file|
      begin
        upload_file_to_s3(s3, bucket, bucket_folder, file)

      rescue Slack::Notifier::APIError => slack_error
        # Halt the backup if we cannot write to Slack; log then raise the error
        log_slack_error(slack_error,
                        "in backup_files.each loop uploading_file_to_s3(#{s3}, #{bucket}, #{bucket_folder}, #{file})",
                        log)
        raise slack_error

      rescue => backup_error
        log_and_notify(backup_error, log)
        next
      end
    end


    # Prune older backups beyond "keep" (days) limit
    log.record('info', 'Pruning older backups on local storage')

    backup_makers.each do |backup_maker|
      begin
        file_pattern = get_backup_files_pattern(backup_dir, backup_maker[:backup_maker].target_filename)
        delete_excess_backup_files(file_pattern, backup_maker[:keep_num])

      rescue Slack::Notifier::APIError => slack_error
        # Halt the backup if we cannot write to Slack; log then raise the error
        log_slack_error(slack_error,
                        "while pruning in the backup_makers.each loop backup_maker = #{backup_maker.pretty_inspect}, file_pattern = #{file_pattern}",
                        log)
        raise slack_error

      rescue => backup_error
        log_and_notify(backup_error, log)
        next
      end
    end


  rescue Slack::Notifier::APIError => slack_error
    # Halt the backup if we cannot write to Slack; log then raise the error
    log_slack_error(slack_error, '(not within a loop)', log)
    raise slack_error

  rescue => backup_error
    log_and_notify(backup_error, log)

  end


  def self.backup_dir(config)
    config.dig(:backup_directory) || DEFAULT_BACKUP_FILES_DIR
  end


  def self.backup_target_fn(backup_dir, backup_base_fn)
    File.join(backup_dir, backup_base_fn + '.' + today_timestamp + '.gz')
  end


  def self.today_timestamp
    Time.now.strftime TIMESTAMP_FMT
  end


  def self.get_s3_objects(today_ts = today_timestamp)

    s3 = Aws::S3::Resource.new(
        region: ENV['SHF_AWS_S3_BACKUP_REGION'],
        credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                          ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))

    bucket = ENV['SHF_AWS_S3_BACKUP_BUCKET']

    bucket_folder = "production_backup/#{today_ts}/" # S3 will show objects in folders

    [s3, bucket, bucket_folder]
  end


  def self.upload_file_to_s3(s3, bucket, bucket_folder, file)
    obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))

    obj.upload_file(file)
  end


  def self.get_backup_files_pattern(backup_dir, beginning_of_file_name)
    File.join(backup_dir, beginning_of_file_name) + '.*'
  end


  def self.delete_excess_backup_files(file_pattern, number_of_files_to_keep)

    backup_files = Dir.glob(file_pattern)

    number_of_backup_files = backup_files.length

    if number_of_backup_files > number_of_files_to_keep

      delete_files = backup_files.sort[0, number_of_backup_files - number_of_files_to_keep]

      delete_files.each { |file| File.delete(file) }
    end
  end


  def self.create_backup_makers(config)
    num_code_backups_to_keep = config.dig(:days_to_keep, :code_backup) || DEFAULT_CODE_BACKUPS_TO_KEEP
    num_db_backups_to_keep = config.dig(:days_to_keep, :db_backup) || DEFAULT_DB_BACKUPS_TO_KEEP
    num_file_backups_to_keep = config.dig(:days_to_keep, :files_backup) || DEFAULT_FILE_BACKUPS_TO_KEEP

    # :keep_num key defines how many daily backups to retain on _local_ storage (e.g. on the production machine)
    # AWS (S3) backup files are retained based on settings in AWS.
    backup_makers = [
        { backup_maker: CodeBackupMaker.new, keep_num: num_code_backups_to_keep },
        { backup_maker: DBBackupMaker.new, keep_num: num_db_backups_to_keep }
    ]

    files_backup_maker = create_files_backup_maker(config)
    backup_makers << { backup_maker: files_backup_maker, keep_num: num_file_backups_to_keep } if files_backup_maker

    backup_makers
  end


  # only create a FilesBackupMaker if there is a list of files to be backed up
  def self.create_files_backup_maker(config)
    files_backup_maker = nil
    if (backup_files = config.fetch(:files, false))

      unless backup_files.is_a?(Array)
        raise ShfConditionError::BackupConfigFilesBadFormatError.new('Backup Condition configuration for :files is bad.  Must be an Array.')
      end

      files_backup_maker = FilesBackupMaker.new(backup_sources: backup_files) unless backup_files.empty?
    end

    files_backup_maker
  end


  # Record the error and additional_info to the given log and send a Slack notification.
  #
  # TODO  this seems like a general-purpose method that we need in many places.  Refactor into a class/module to be available all places
  #
  #
  # @param [Error] error - Error that needs to be recorded
  # @param [Log] log - the log to write to. Must respond to :error(message)
  # @param [String] additional_info - any additional information that should also be recorded. Default = ''
  #
  def self.log_and_notify(error, log, additional_info = '')

    log_string = additional_info&.empty? ? error.to_s : "#{error} #{additional_info}"

    log.error(log_string)
    SHFNotifySlack.failure_notification(self.name, text: log_string)

    # If the problem is because of Slack Notification, log it and raise it
    #  so the caller can deal with it as needed.
  rescue Slack::Notifier::APIError => slack_error

    log.error("Slack error during #{self.name}.#{__method__}: #{slack_error.inspect}")
    raise slack_error

    # ... Otherwise, an exception was raised during writing to the log.
    # Send a slack notification about that and continue (do _not_ raise it).
  rescue => not_a_slack_error
    # send the original notification
    SHFNotifySlack.failure_notification(self.name, text: log_string)

    # send another notification about this error
    SHFNotifySlack.failure_notification(self.name, text: "Error: Could not write to the log in #{self.name}.#{__method__}: #{not_a_slack_error}")
  end


  def self.slack_error_encountered_str(during_method = 'condition_response')
    "Slack Notification failure during #{self.name}.#{during_method}"
  end

  # Only log the error if it has not already been logged.
  def self.log_slack_error(slack_error, details, log)
    log.error("#{slack_error_encountered_str} #{details}: #{slack_error}") unless @slack_error_already_logged
    @slack_error_already_logged = true
  end
end
