# @description Configuration information for the OneTimeTaskRunner
#
# @file config/initializers/one_time_task_runner.rb

# FIXME - this should configure the Runner, which will tell the Finder where to look
if defined?(OneTimeTaskRunner::OneTimeTasksFinder)

  OneTimeTaskRunner::OneTimeTasksFinder.configure do |config|

    # This is the directory where all .rake files should be for the Rake::Tasks to be run once.
    # This directory can contain subdirectories; all subdirectories will be searched under this one.
    config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')

    # This is the name of the logfile that the OneTimeTaskRunner will LOOK IN to see if a task has been run.
    # config.logfile = ''

  end

end
