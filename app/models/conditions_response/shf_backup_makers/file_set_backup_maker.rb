module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::FileSetBackupMaker
  #
  # @desc Responsibility: Create a backup using tar to compress the sources together
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  class FileSetBackupMaker < AbstractBackupMaker

    CODE_ROOT_DIRECTORY = '/var/www/shf/current/'
    LOGS_ROOT_DIRECTORY = '/var/log'

   # attr_accessor :name, :description

    # name is required, so it is a required argument here
    # def initialize(name,
    #                target_filename: base_filename,
    #                backup_sources: default_sources)
    #
    #   raise ShfConditionError::BackupConfigFileBackupMissingName if name.blank?
    #
    #   @name = name
    #   @description = ''
    #
    #   super(target_filename: target_filename,
    #         backup_sources: backup_sources)
    #
    # end


    # use tar to compress all sources into the file named by target
    # @return [String] - the name of the backup target created
    def backup(target: target_filename, sources: backup_sources)
      shell_cmd("tar -chzf #{target} #{sources.join(' ')}")
      target
    end

  end

end
