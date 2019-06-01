require_relative File.join(__dir__, '..', '..', 'app', 'models', 'logfile_namer')


module OneTimeTaskRunner

#--------------------------
#
# @class OneTimeTasksFinder
#
# @desc Responsibility: Find any 'one time' rake tasks that should be run today
#   This will look for .rake task files in the
#
#   Tasks must follow a certain folder and file naming convention:

#
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-05-21
#
# @file one_time_tasks_finder
#
#--------------------------
  class OneTimeTasksFinder

    include Singleton


    ONETIME_TASKS_DIRECTORY = 'one_time' unless defined?(ONETIME_TASKS_DIRECTORY)
    DEFAULT_TASKS_DIR       = File.join(Rails.root, 'lib', 'tasks', ONETIME_TASKS_DIRECTORY) unless defined?(DEFAULT_TASKS_DIR)

    SHFDEPLOY_LOG_NAME      = 'SHF-deploy' unless defined?(SHFDEPLOY_LOG_NAME)
    DEFAULT_SOURCE_LOGNAME  = LogfileNamer.name_for(SHFDEPLOY_LOG_NAME)


    attr_accessor :logfile, :tasks_directory


    # Configure the OneTimeTasksFinder
    #
    # @example  This can be used in config/initializers/one_time_task_runner.rb
    #
    #   OneTimeTasksFinder.configure | config |
    #     config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')
    #   end
    #
    #
    def configure
      yield self
    end


    def tasks_directory
      @tasks_directory ||= DEFAULT_TASKS_DIR
    end


    def logfile
      @logfile ||= DEFAULT_SOURCE_LOGNAME
    end


    # Returns a list of Rake::Tasks names that
    #  (1) have not been run yet, and
    #  (2) are in a .rake file that is in directory that meets the pattern matching criteria
    def names_of_tasks_to_run_today

      rakefiles = onetime_rake_files

      # Tasks in the rakefiles. This will not load or return tasks already loaded or global tasks.
      onetime_rake = Rake.with_application do
        rakefiles.each { |rakefile| Rake.load_rakefile(File.join(onetime_tasks_path, rakefile)) }
      end

      onetime_rake.tasks.reject { |task| has_task_been_run?(task) }.map(&:name)
    end


    # All files in directories that meet the criteria
    def onetime_rake_files

      return [] unless Dir.exist?(onetime_tasks_path) && !Dir.empty?(onetime_tasks_path)

      all_rakefiles = Dir.glob(File.join("**", "*.rake"), base: onetime_tasks_path)

      all_rakefiles.select { |rakefile| directory_name_meets_criteria?(rakefile) }
    end


    # true if the directory name matches the pattern for this year, this quarter
    # FIXME - Is this needed?  If a task has not been run, run it.
    def directory_name_meets_criteria?(path)

      now       = Time.zone.now
      this_year = now.year
      this_qtr  = (now.month / 3.0).ceil

      match_pattern = /\A(\/)?#{this_year}_[Qq]#{this_qtr}\/(.*)\.rake\z/

      match_pattern.match(path) ? true : false
    end


    def has_task_been_run?(task_name)
      task_in_log_file?(task_name, logfile)
    end


    def task_in_log_file?(task_name, logfilepath)
      File.exist?(logfilepath) && File.read(logfilepath).include?(task_log_entry_str(task_name))
    end


    def task_log_entry_str(task_name)
      "One-time task #{task_name} was run on"
    end


    def onetime_tasks_path
      self.tasks_directory
    end

  end

end
