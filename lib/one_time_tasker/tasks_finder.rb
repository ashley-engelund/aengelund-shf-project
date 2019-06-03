module OneTimeTasker

  #--------------------------
  #
  # @class TasksFinder
  #
  # @desc Responsibility: Get all 'one time' rake tasks that should be run.
  #   Warn if duplicate task names should be run and mark them as 'attempt failed'.
  #
  #   1. Get all one time rake tasks that should be run:
  #   This will look for all .rake task files in the :tasks_directory and then get
  #   all tasks in them.
  #   A task should be run if and only if there is _not_ a OneTimeTasker::TaskAttempt
  #      with the same task name AND .was_successful? == true
  #
  #   2. Warn if duplicate task names are found and record failed TaskAttempts for them:
  #   If there are tasks with the same name _and_ they all should be run
  #   then this will create a failed TaskAttempt for each of them and record 'duplicate task..' in the notes attribute/column.
  #     Ex:
  #        subdir_A/rake_file_1.rake  has a task named 'shf:task_a'
  #        subdir_B/rake_file_1.rake  has a task named 'shf:task_a'
  #        subdir_B/rake_file_2.rake  has a task named 'shf:task_a'
  #
  #     and none of these tasks have been run successfully yet: there is
  #     no TaskAttempt with task_name == 'shf:task_a'
  #
  #     (See the RSpec for this class)
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-05-21
  #
  # @file one_time_tasks_finder
  #
  #--------------------------
  class TasksFinder

    DEFAULT_ONE_TIME_TASKS_DIR = File.join(Rails.root, 'lib', 'tasks', 'one_time') unless defined?(DEFAULT_ONE_TIME_TASKS_DIR)

    # FIXME - I18n locale file for this.
    DUPLICATE_TASK_MSG = 'This task is a duplicate: more than 1 task to be run has this task name. This task cannot be run. Rename it or the other duplicate(s).'


    # This is the directory that the TasksFinder will look for .rake files.
    # It will search in this directory and any and all subdirectories.
    # Th
    mattr_accessor :tasks_directory
    @@tasks_directory = DEFAULT_ONE_TIME_TASKS_DIR


    # Configure the TasksFinder
    #
    # @example  This can be used in config/initializers/tasks_finder.rb
    #
    #   OneTimeTasker::TasksFinder.configure do | config |
    #     config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')
    #   end
    #
    #
    def self.configure
      yield self
    end


    def files_with_tasks_to_run
      @files_with_tasks_to_run_today ||= get_files_and_their_tasks
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


    # for resetting to the original default
    def self.default_tasks_directory
      DEFAULT_ONE_TIME_TASKS_DIR
    end


    def default_tasks_directory
      self.class.default_tasks_directory
    end

    # --------------------------------------------------------------------------


    private


    # Get all tasks in all rake files that should be run,
    # then remove any duplicates.
    #
    # @return [Hash] - the rake files and their tasks that should be run
    #   key = the full path to a rake file
    #   value = list of the tasks in the rake file that should be run
    #
    def get_files_and_their_tasks

      files_and_all_tasks = files_with_all_tasks_to_run
      remove_duplicates_and_record(files_and_all_tasks)
    end


    # Returns a Hash where the key = the rake file name and
    # the value is the list of tasks to be run today that are in that file.
    # A task is to be run if and only if it has not already be successfully run.
    def files_with_all_tasks_to_run
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


    # If there are tasks with the same name ( == duplicates),
    # then:
    #   record a failed TaskAttempt for each one, noting the duplication in the notes
    #   log an error
    #   remove them from the files_and_tasks
    #
    def remove_duplicates_and_record(files_and_tasks)

      # get all of the task_names that are duplicates (values.flatten = all task names),
      #  .group_by ... will get all duplicates
      duplicate_names = files_and_tasks.values.flatten.group_by { |e| e }.select { |_k, v| v.size > 1 }.map(&:first)

      # Guard condition: no duplicate names, so just return
      return files_and_tasks if duplicate_names.empty?

      # create a list of [task, the rakefile for the task] from the Hash of {filename => [tasks]} for the duplicates
      # We need this so that we can record the filename for any duplicates
      task_filenames_dups = []
      files_and_tasks.each { |filename, tasknames| tasknames.each { |taskname| task_filenames_dups << [taskname, filename] if duplicate_names.include?(taskname) } }

      # position indices for information in the list elements we just created (to be really clear)
      taskname_position = 0
      filename_position = 1

      task_filenames_dups.each do |task_duplicate|
        taskname = task_duplicate[taskname_position]
        filename = task_duplicate[filename_position]

        record_failure_and_log(taskname, filename)
        files_and_tasks = remove_files_and_tasks_duplicate(files_and_tasks, filename, taskname)
      end

      files_and_tasks.compact
    end


    def remove_files_and_tasks_duplicate(files_and_tasks, filename, taskname)
      files_and_tasks[filename].delete(taskname)
      files_and_tasks[filename] = nil if files_and_tasks[filename].empty?
      files_and_tasks
    end


    def record_failure_and_log(task_name, rake_filename)
      record_as_failed_duplication(task_name, rake_filename)
      log_as_duplicate(task_name, rake_filename)
    end


    def record_as_failed_duplication(task_name, rake_file_source)
      OneTimeTasker::FailedTaskAttempt.create(task_name:   task_name,
                                              task_source: rake_file_source,
                                              notes:       DUPLICATE_TASK_MSG)
    end


    def log_as_duplicate(task_name, rake_file_source)

      ActivityLogger.open(LogfileNamer.name_for(self.class),
                          self.class.name.upcase,
                          __callee__) do |log|
        log.error(duplicate_task_log_entry(task_name, rake_file_source))
      end

    end


    def duplicate_task_log_entry(task_name, rake_file_source)
      "Duplicate task name! Task named '#{task_name}' in the file #{rake_file_source}: #{DUPLICATE_TASK_MSG}"
    end
  end

end
