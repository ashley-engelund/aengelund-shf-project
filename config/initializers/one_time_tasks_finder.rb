# @description Configuration information for the OneTimeTasker::OneTimeTasksFinder
#
# @file config/initializers/one_time_tasks_finder.rb

if defined?(OneTimeTasker::OneTimeTasksFinder)

  OneTimeTasker::OneTimeTasksFinder.instance.configure do |config|

    # This is the directory where all .rake files should be for the Rake::Tasks to be run once.
    # This directory can contain subdirectories; all subdirectories will be searched under this one.
    config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')

  end

end
