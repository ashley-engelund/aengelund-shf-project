require 'rails_helper'

require_relative File.join(__dir__, '..', '..', '..', 'lib', 'one_time_tasker', 'one_time_tasks_finder')
require 'rake'

require 'shared_context/activity_logger'
require 'shared_context/simple_rake_task_files_maker'


RSpec.describe OneTimeTasker::OneTimeTasksFinder, type: :model do

  include_context 'create logger'
  include_context 'simple rake task files maker'

  let(:subject) { described_class.instance }


  describe 'files_with_tasks_to_run_today' do

    it 'Hash with each key a full rake file path and value = the list of tasks to run in that file' do

      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 2 .rake files in the 2019_Q2 directory (task0, task1)
      q2_rakefiles = make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 2)

      # Create 1 .rake file in a subdirectory named 'blorfo' (task2)
      blorfo_rakefiles = make_simple_rakefiles_under_subdir(temp_onetime_path, 'blorfo', )
      blorfo_rakefile = blorfo_rakefiles.first

      # add 2 other tasks to blorfo_rakefile
      task2_in_file = simple_rake_task('task1_in_the_blorfo_rake_file')
      task3_in_file = simple_rake_task('task2_in_the_blorfo_rake_file')

      File.open(blorfo_rakefile, 'a') do |f|
        f.puts task2_in_file
        f.puts task3_in_file
      end

      # Record blorfo/test1.rake task0 as having been attempted but _failed_
      create(:one_time_tasker_task_attempt, :unsuccessful_task, task_name: 'shf:test:task0')

      # Record blorfo/test1.rake task1_in_the_blorfo_rake_file as having been attempted and succeeded
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1_in_the_blorfo_rake_file')

      actual_files_with_tasks = subject.files_with_tasks_to_run_today

      expect(actual_files_with_tasks.keys).to match_array(q2_rakefiles + blorfo_rakefiles)

      # one task in  2019_Q2/test1.rake
      expect(actual_files_with_tasks[q2_rakefiles.first]).to match_array(['shf:test:task0'])

      # one task in  2019_Q2/test2.rake
      expect(actual_files_with_tasks[q2_rakefiles.second]).to match_array(['shf:test:task1'])


      # two tasks in the blorfo_rakefile should be run (task1 was already run successfully)
      expect(actual_files_with_tasks[blorfo_rakefile]).to match_array(['shf:test:task0',  'shf:test:task2_in_the_blorfo_rake_file'])
    end


    context 'is empty if' do

      it 'no rake files found' do
        temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
        allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

        expect(subject.files_with_tasks_to_run_today).to be_empty
      end

      it 'no tasks in the rake files' do
        temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
        allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

        # create 3 empty .rake files
        3.times do | i |
          filepath_created = File.join(File.absolute_path(temp_onetime_path), "task_#{i}.rake")
          File.open(filepath_created, 'w') do |f|
            f.puts ''
          end
        end

        expect(subject.files_with_tasks_to_run_today).to be_empty
      end

      it 'all tasks have been successfully run' do
        temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
        allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

        # Create 3 .rake files in the 2019_Q2 directory
        make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 3)

        # Record task0, task1, and task2 as already been run successfully
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0')
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1')
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')

        expect(subject.files_with_tasks_to_run_today).to be_empty
      end
    end

  end


  describe 'names_of_tasks_to_run_today' do

    it 'only those tasks that have not yet been run' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 4 .rake files and in the 2019_Q2 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 4)

      # Record task0 and task2 as already been run successfully
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0')
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')

      expect(subject.names_of_tasks_to_run_today).to match_array(['shf:test:task1', 'shf:test:task3'])
    end


    it 'gets all tasks in a .rake file (can handle multiple tasks in a .rake file)' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 1 .rake file and in the 2019_Q2 directory
      simple_rakefiles = make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 1)

      # add 2 other tasks to the .rake file
      task2_in_file = simple_rake_task('task1_in_file')
      task3_in_file = simple_rake_task('task2_in_file')

      File.open(simple_rakefiles.first, 'a') do |f|
        f.puts task2_in_file
        f.puts task3_in_file
      end

      expect(subject.names_of_tasks_to_run_today).to match_array(['shf:test:task0', 'shf:test:task1_in_file', 'shf:test:task2_in_file'])
    end


    it 'empty list if all tasks have been run' do

      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 3 .rake files in the 2019_Q2 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 3)

      # Record task0, task1, and task2 as already been run successfully
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0')
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1')
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')

      expect(subject.names_of_tasks_to_run_today).to be_empty
    end


    it 'subdirectory names do not matter' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 3 .rake files in the 1990_Q3 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '1990_Q3', 3)

      expect(subject.names_of_tasks_to_run_today).to match_array(["shf:test:task0", "shf:test:task1", "shf:test:task2"])
    end

  end


  describe 'onetime_rake_files' do

    it 'empty if the onetime path does not exist' do
      allow(subject).to receive(:onetime_tasks_path).and_return('blorf')

      expect(subject.onetime_rake_files).to be_empty
    end

    it 'empty if no .rake files' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      expect(subject.onetime_rake_files).to be_empty
    end

    it 'only returns .rake files' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 1 .rake file in the directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '.', 1)

      # Create 3 .rake files in the 'blorfo' subdirectory
      make_simple_rakefiles_under_subdir(temp_onetime_path, 'blorfo', 3)

      # Create 2 .rake files in the 'flurb' subdirectory
      make_simple_rakefiles_under_subdir(temp_onetime_path, 'flurb', 2)

      # Create some files that do not have a .rake extension
      not_rake_files = ['blorf.rake.txt', 'blorf.txt', 'blorf', 'rake']
      not_rake_files.each do |not_a_rake_file|
        filepath_created = File.join(File.absolute_path(temp_onetime_path), not_a_rake_file)
        File.open(filepath_created, 'w') do |f|
          f.puts 'blorf is here'
        end
      end

      expect(subject.onetime_rake_files).to match_array(["test0.rake", "blorfo/test0.rake", "blorfo/test1.rake", "blorfo/test2.rake", "flurb/test0.rake", "flurb/test1.rake"])
    end

    it 'ignores a file a file named .rake (the extension only)' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create a file that is named ".rake"  It wil
      filepath_created = File.join(File.absolute_path(temp_onetime_path), '.rake')
      File.open(filepath_created, 'w') do |f|
        f.puts 'this file is named with only the .rake extension'
      end

      expect(subject.onetime_rake_files).to be_empty
    end

  end


  describe 'task_was_successful?' do

    before(:all) do
      FauxRakeTask = Struct.new(:name)
    end

    let(:successful_task) { FauxRakeTask.new('successful task') }
    let(:unsuccessful_task) { FauxRakeTask.new('unsuccessful task') }


    it 'false if it is not in the db' do
      not_in_db = FauxRakeTask.new('not in db')
      expect(subject.task_was_successful?(not_in_db)).to be_falsey
    end

    it 'true only if if the task was attempted and was_successful' do
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'successful task')
      expect(subject.task_was_successful?(successful_task)).to be_truthy

      create(:one_time_tasker_task_attempt, :unsuccessful_task, task_name: 'unsuccessful task')
      expect(subject.task_was_successful?(unsuccessful_task)).to be_falsey
    end

  end


  describe 'configuration' do

    describe 'default configuration' do

      it "tasks_directory default is File.join(Rails.root, 'lib', 'tasks', 'one_time')" do
        # Because it is a Singleton, if a randomly run test has changed the tasks_directory,
        # the result will not be the default. So we must explicitly query the constant.
        expect(described_class::DEFAULT_TASKS_DIR).to eq File.join(Rails.root, 'lib', 'tasks', 'one_time')
      end
    end


    it 'specify a tasks directory to use' do

      temp_task_dir_path = Dir.mktmpdir('test-task-dir-path')

      make_simple_rakefiles_under_subdir(temp_task_dir_path, '.', 2)

      subject.tasks_directory = temp_task_dir_path

      expect(subject.onetime_rake_files).to match_array(['test0.rake', 'test1.rake'])
    end

  end

end
