module OneTimeTasker

#--------------------------
#
# @class OneTimeTasksFinder
#
# @desc Responsibility: Find any 'one time' rake tasks that should be run.
#   This will look for all .rake task files in the :tasks_directory and then get
#   all tasks in them.
#   A task should be run if and only if there is _not_ a OneTimeTasker::TaskAttempt
#      with the same task name AND .was_successful? == true
#
#   If there are tasks with the same name _and_ they all should be run
#   then this will create a failed TaskAttem for each of them and record 'duplicate task..' in the notes attribute/column.
#     Ex:
#        subdir_A/rake_file_1.rake  has a task named 'shf:task_a'
#        subdir_B/rake_file_1.rake  has a task named 'shf:task_a'
#        subdir_B/rake_file_2.rake  has a task named 'shf:task_a'
#
#     and none of these tasks have been run successfully yet: there is
#     no TaskAttempt with task_name == 'shf:task_a'
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

    DEFAULT_TASKS_DIR = File.join(Rails.root, 'lib', 'tasks', 'one_time') unless defined?(DEFAULT_TASKS_DIR)

    attr_accessor :tasks_directory


    # Configure the OneTimeTasksFinder
    #
    # @example  This can be used in config/initializers/one_time_tasks_finder.rb
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


    # FIXME: what if 2 different files have a task with the exact same name?
    #  Warn and do not run.


    def files_with_tasks_to_run_today
      @files_with_tasks_to_run_today ||= get_files_with_tasks_to_run_today
    end


    # Returns a list of all Rake::Tasks names that have not been successfully run yet
    def names_of_tasks_to_run_today
      self.files_with_tasks_to_run_today.values
    end


    # All .rake files in the onetime_tasks_path
    def onetime_rake_files
      return [] unless Dir.exist?(onetime_tasks_path) && !Dir.empty?(onetime_tasks_path)

      Dir.glob(File.join("**", "*.rake"), base: onetime_tasks_path)
    end


    def task_was_successful?(task)
      !OneTimeTasker::TaskAttempt.successful.find_by(task_name: task.name).nil?
    end


    def onetime_tasks_path
      self.tasks_directory
    end


    # --------------------------------------------------------------------------


    private

    # Returns a Hash where the key = the rake file name and
    # the value is the list of tasks to be run today that are in that file.
    # A task is to be run if and only if it has not already be successfully run.
    def get_files_with_tasks_to_run_today
      rake_files_with_tasks = {}

      onetime_rake_files.each do |rakefile|

        full_rakefile_path = File.absolute_path(File.join(onetime_tasks_path, rakefile))

        # Get the Rake::Tasks in the rakefiles.
        # This will not load or return tasks already loaded or global tasks.
        onetime_rake_tasks = Rake.with_application do
          Rake.load_rakefile(full_rakefile_path)
        end

        tasks_to_run                              = onetime_rake_tasks.tasks.reject(&method(:task_was_successful?)).map(&:name)

        rake_files_with_tasks[full_rakefile_path] = tasks_to_run unless tasks_to_run.empty?
      end

      rake_files_with_tasks
    end

  end

end
