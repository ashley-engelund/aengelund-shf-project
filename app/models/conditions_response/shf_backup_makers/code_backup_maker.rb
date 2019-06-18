module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::CodeBackupMaker
  #
  # @desc Responsibility: Create a backup of the code for the system
  #         The base filename is 'current.tar' = the default name of the backup created
  #         The default list of sources is the application directory
  #
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  # Backup a list of code directories.  Create 1 resulting backup file 'current.tar'
  class CodeBackupMaker < FileSetBackupMaker

    # exclude:
    # - files in .gitignore (they should be backed up in other file sets, e.g. /config/secrets.yml, .env
    # /spec
    # /features
    # /docs
    # /public
    # /log
    # /tmp
    #

    DEFAULT_SOURCES = [CODE_ROOT_DIRECTORY]
    DEFAULT_BACKUP_FILEBASE = 'current.tar'


    def base_filename
      DEFAULT_BACKUP_FILEBASE
    end


    def default_sources
      [CODE_ROOT_DIRECTORY]
    end
  end

end
