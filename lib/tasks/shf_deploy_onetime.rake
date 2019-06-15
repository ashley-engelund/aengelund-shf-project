# Tasks to run to deploy the application.  Tasks defined here can be called by capistrano.

require_relative '../one_time_tasker/tasks_runner'
require 'active_support/logger'


namespace :shf do

  namespace :one_time do


    desc 'Run any one time tasks not yet run. Rename rakefiles that run completely successfully. Argument = directory of rakefiles; default = Rails.root/lib/tasks/one_time'
    task :run_onetime_tasks, [:rakefiles_dir] => [:environment] do |task_name, args|

      error_encountered = false
      default_dir = File.join(Rails.root, 'lib', 'tasks', 'one_time')
      base_dir = default_dir

      if args.has_key? :rakefiles_dir
        given_dir = File.join(FileUtils.pwd, args[:rakefiles_dir])

        if Dir.exist?(given_dir)
          base_dir = given_dir
        else
          puts "\n#{task_name} ERROR: directory does not exist: #{File.absolute_path(given_dir)}\n   No rakefiles read or tasks run.\n"
          error_encountered = true
        end
      end

      unless error_encountered

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
