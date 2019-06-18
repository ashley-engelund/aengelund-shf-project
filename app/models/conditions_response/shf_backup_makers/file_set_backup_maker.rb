require_relative File.join(__dir__, '..', 'shf_condition_error_backup_errors.rb')

#--------------------------
# Errors
module ShfConditionError

  class BackupFileSetMissingNameError < BackupError
  end

  class BackupFileSetNameCantBeBlankError < BackupError
  end

end
#--------------------------


module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::FileSetBackupMaker
  #
  # @desc Responsibility: Create a backup using tar to compress the sources together.
  #     The backup has a name and description to describe this set of files
  #     that comprise the backup. It must have a name; description is optional.
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  class FileSetBackupMaker < AbstractBackupMaker

    CODE_ROOT_DIRECTORY = '/var/www/shf/current/'
    LOGS_ROOT_DIRECTORY = '/var/log'

    attr_accessor :name, :description


    # possible named arguments: (name:, description:, target_filename:, backup_sources:)
    # name: is required
    def initialize(args)

      name = args.fetch(:name, false)
      raise ShfConditionError::BackupFileSetMissingNameError unless name
      raise ShfConditionError::BackupFileSetNameCantBeBlankError if name.blank?

      @name = name
      @description = args.fetch(:description, '')

      super_args = args.reject{|key, _value| key == :name || key == :description}

      super(super_args)
    end


    # use tar to compress all sources into the file named by target
    # @return [String] - the name of the backup target created
    def backup(target: target_filename, sources: backup_sources)
      shell_cmd("tar -chzf #{target} #{sources.join(' ')}")
      target
    end

  end

end
