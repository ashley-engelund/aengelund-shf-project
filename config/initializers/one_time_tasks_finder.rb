# @description Configuration information for the OneTimeTasker::TasksFinder
#
# @file config/initializers/tasks_finder.rb

if defined?(OneTimeTasker::TasksFinder)

  OneTimeTasker::TasksFinder.configure do |config|

    # This is the directory where all .rake files should be for the Rake::Tasks to be run once.
    # This directory can contain subdirectories; all subdirectories will be searched under this one.
    # Default is:  File.join(Rails.root, 'lib', 'tasks', 'one_time')
    config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')

  end

end
