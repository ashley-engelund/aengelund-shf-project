# Tasks to run to deploy the application.  Tasks defined here can be called by capistrano.

require_relative '../one_time_tasker/tasks_runner'
require 'active_support/logger'


namespace :shf do

  namespace :one_time do

    DEFAULT_ONETIME_TASKS_DIR = File.join(Rails.root, 'lib', 'tasks', 'one_time') unless defined?(DEFAULT_ONETIME_TASKS_DIR)


    def args_ok?(args)
      args_are_ok = true

      if args.has_key? :rakefiles_dir
        given_dir = dir_with_pwd(args[:rakefiles_dir])

        unless Dir.exist?(given_dir)
          puts "\n#{task_name} ERROR: directory does not exist: #{File.absolute_path(given_dir)}\n   No rakefiles read.\n"
          args_are_ok = false
        end
      end
      args_are_ok
    end


    def dir_with_pwd(dir)
      File.join(FileUtils.pwd, dir)
    end


    def set_basedir_from_args(args)
      args.has_key?(:rakefiles_dir) ? dir_with_pwd(args[:rakefiles_dir]) : DEFAULT_ONETIME_TASKS_DIR
    end


    # Run this task manually before ever running :run_onetime_tasks
    #  (No tasks are run, but the code is read so any syntax errors will be noted.)
    #
    # 1. get all of the rake files and their tasks
    # 2. set them as successfully run:
    #    For each rakefile:
    #      a) create and save a SuccessfulTask for each task in the file
    #      b) rename the file
    #
    desc 'Set all one-time task files to *.ran; add as SuccessfulTasks to db. Argument = directory of rakefiles; default = Rails.root/lib/tasks/one_time'
    task :set_prev_onetime_tasks_as_ran, [:rakefiles_dir] => [:environment] do |task_name, args|

      if args_ok?(args)
        base_dir = set_basedir_from_args(args)

        logfile_name = LogfileNamer.name_for('SHF-task-set_prev_onetime_tasks_as_ran')
        ActivityLogger.open(logfile_name,
                            'SHF',
                            task_name, false
        ) do |log|
          OneTimeTasker::TasksRunner.set_or_create_log(log,
                                                       log_facility_tag: OneTimeTasker::TasksRunner.log_facility_tag,
                                                       log_activity_tag: OneTimeTasker::TasksRunner.log_activity_tag)

          tasks_finder = OneTimeTasker::TasksFinder.new(log, logging: true)
          tasks_finder.tasks_directory = base_dir

          task_files_and_names = tasks_finder.files_with_tasks_to_run

          task_files_and_names.each do |_rakefile, ev_rakefile|
            rakefilename = ev_rakefile.filename
            ev_rakefile.tasks_to_run.each do |ev_task|
              OneTimeTasker::SuccessfulTaskAttempt.create(task_name: ev_task.name,
                                                          task_source: rakefilename)
              log.info("A SuccessfulTaskAttempt was recorded for the one-time task #{ev_task.name} (previously run).")
            end
            OneTimeTasker::TasksRunner.rename_rakefile(rakefilename) # this logs the files renamed
          end
        end
      end

    end


    desc 'Run any one time tasks not yet run. Rename rakefiles that run completely successfully. Argument = directory of rakefiles; default = Rails.root/lib/tasks/one_time'
    task :run_onetime_tasks, [:rakefiles_dir] => [:environment] do |task_name, args|

      if args_ok?(args)
        base_dir = set_basedir_from_args(args)

        OneTimeTasker::TasksRunner.tasks_directory = base_dir
        logfile_name = LogfileNamer.name_for(OneTimeTasker)

        ActivityLogger.open(logfile_name,
                            'SHF',
                            task_name, false
        ) do |log|
          OneTimeTasker::TasksRunner.run_onetime_tasks(log)
        end
      end
    end

  end

end
