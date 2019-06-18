# Backup code and DB data in production


# Errors
module ShfConditionError
  class BackupError < StandardError
  end

  class BackupConfigFilesBadFormatError < BackupError
  end

  class BackupCommandNotSuccessfulError < BackupError
  end
end


class Backup < ConditionResponder


  DEFAULT_BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'
  DEFAULT_CODE_BACKUPS_TO_KEEP = 4
  DEFAULT_DB_BACKUPS_TO_KEEP = 15
  DEFAULT_FILE_BACKUPS_TO_KEEP = 31

  TIMESTAMP_FMT = '%Y-%m-%d'

  # -------------


  # TODO: Slack notification may or may not be used (= the use_slack_notification flag).
  def self.condition_response(condition, log)

    @slack_error_already_logged = false # keep us from logging a Slack error every time it percolates up through rescue blocks

    validate_timing(get_timing(condition), [TIMING_EVERY_DAY], log)

    config = get_config(condition)
    backup_makers = create_backup_makers(config)

    # Backup each backup_maker to local storage
    backup_files = []
    backup_dir = backup_dir(config)

    iterate_and_log_notify_errors(backup_makers, 'while in the backup_makers.each loop', log) do |backup_maker|

      # Create a full file path that will be in the backup_directory,
      # and have the filename and extension provided by the backup_maker,
      # but with with date and '.gz' appended.
      backup_file = backup_target_fn(backup_dir, backup_maker[:backup_maker].base_filename)
      backup_files << backup_file

      log.record('info', "Backing up to: #{backup_file}")

      # this will use the default backup sources set when the backup_maker was created
      backup_maker[:backup_maker].backup(target: backup_file)
    end


    log.record('info', 'Moving backup files to AWS S3')
    s3, bucket, bucket_folder = get_s3_objects(today_timestamp)

    iterate_and_log_notify_errors(backup_files, 'in backup_files loop, uploading_file_to_s3', log) do |backup_file|
      upload_file_to_s3(s3, bucket, bucket_folder, backup_file)
    end


    log.record('info', 'Pruning older backups on local storage')

    iterate_and_log_notify_errors(backup_makers, 'while pruning in the backup_makers.each loop', log) do |backup_maker|
      file_pattern = get_backup_files_pattern(backup_dir, backup_maker[:backup_maker].base_filename)
      delete_excess_backup_files(file_pattern, backup_maker[:keep_num])
    end


  rescue Slack::Notifier::APIError => slack_error
    # Halt the backup if we cannot write to Slack; log then raise the error
    log_slack_error(slack_error, log, '(in rescue at bottom of condition_response)')
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


  def self.get_backup_files_pattern(backup_dir, filename)
    File.join(backup_dir, filename) + '.*'
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
        { backup_maker: ShfBackupMakers::CodeBackupMaker.new, keep_num: num_code_backups_to_keep },
        { backup_maker: ShfBackupMakers::DBBackupMaker.new, keep_num: num_db_backups_to_keep }
    ]

    files_backup_maker = create_files_backup_maker(config)
    backup_makers << { backup_maker: files_backup_maker, keep_num: num_file_backups_to_keep } if files_backup_maker

    backup_makers
  end


  # TODO create 1 FileSetBackupMaker for each definition in the config?
  #   name of the files_backup (= 'set name')
  #   # days to keep
  #   list of source files
  #   base_backup_filename
  #
  #  - /public = DATA
  #
  #  - config and .env
  #    /config (will include secrets.yml.
  #      exclude config/initializers (this is code)
  #    .env
  #
  #  - /docs keep: 1
  #
  #
  #
  # only create a FileSetBackupMaker if there is a list of files to be backed up
  def self.create_files_backup_maker(config)
    files_backup_maker = nil
    if (backup_files = config.fetch(:files, false))

      unless backup_files.is_a?(Array)
        raise ShfConditionError::BackupConfigFilesBadFormatError.new('Backup Condition configuration for :files is bad.  Must be an Array.')
      end

      files_backup_maker = ShfBackupMakers::FileSetBackupMaker.new(backup_sources: backup_files) unless backup_files.empty?
    end

    files_backup_maker
  end


  # Iterate through the list, rescuing errors. If it's a Slack error,
  # log and raise the error (stop iterating).
  # For any other error, log  and send a notification
  # and continue iterating via the 'next' keyword.
  #
  # @param [Enumerable] list - items we are iterating through
  # @param [String] additional_error_info - additional information to include
  #                  when logging or notifying
  # @param [Log] log - the log to write to
  #
  def self.iterate_and_log_notify_errors(list, additional_error_info, log)

    list.each do |item|
      yield(item)

    rescue Slack::Notifier::APIError => slack_error
      # Halt the backup if we cannot write to Slack; log then raise the error
      log_slack_error(slack_error, log, "#{additional_error_info}. Current item: #{item.inspect}")
      raise slack_error

    rescue => backup_error
      log_and_notify(backup_error, log, "#{additional_error_info}. Current item: #{item.inspect}")
      next
    end
  end


  # Record the error and additional_info to the given log and send a Slack notification.
  #
  # TODO  this seems like a general-purpose method that we need in many places.  Refactor into a class/module to be available all places
  #
  #
  # @param [Error] original_error - Error that needs to be recorded
  # @param [Log] log - the log to write to. Must respond to :error(message)
  # @param [String] additional_info - any additional information that should also be recorded. Default = ''
  #
  def self.log_and_notify(original_error, log, additional_info = '')

    log_string = additional_info.blank? ? original_error.to_s : "#{original_error} #{additional_info}"

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
    # send a notification about the original error
    SHFNotifySlack.failure_notification(self.name, text: log_string)

    # send another notification about the error that happened in this method
    SHFNotifySlack.failure_notification(self.name, text: "Error: Could not write to the log in #{self.name}.#{__method__}: #{not_a_slack_error}")
  end


  def self.slack_error_encountered_str(during_method = 'condition_response')
    "Slack Notification failure during #{self.name}.#{during_method}"
  end


  # Only log the error if it has not already been logged.
  def self.log_slack_error(slack_error, log, details = '')
    log.error("#{slack_error_encountered_str} #{details}: #{slack_error}") unless @slack_error_already_logged
    @slack_error_already_logged = true
  end

end
