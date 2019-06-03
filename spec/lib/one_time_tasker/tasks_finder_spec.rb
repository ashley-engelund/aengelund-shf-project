require 'rails_helper'

require_relative File.join(__dir__, '..', '..', '..', 'lib', 'one_time_tasker',  'tasks_finder')
require 'rake'

require 'shared_context/activity_logger'
require 'shared_context/simple_rake_task_files_maker'

# ------------------------------------------------------------------------------

RSpec.shared_examples 'it changes FailedTaskAttempts and has SuccessfulTaskAttempts' do |num_failed, num_successful |

  it "changed FailedTaskAttempts by #{num_failed}" do
    expect { subject.files_with_tasks_to_run }.to change(OneTimeTasker::FailedTaskAttempt, :count).by(num_failed)
  end

  describe 'TaskAttempts' do
    before(:each) { subject.files_with_tasks_to_run }

    it "#{num_failed} FailedTaskAttempts" do
      expect(OneTimeTasker::FailedTaskAttempt.count).to eq num_failed
    end

    it "#{num_successful} SuccessfulTaskAttempts" do
      expect(OneTimeTasker::SuccessfulTaskAttempt.count).to eq num_successful
    end
  end

end


RSpec.shared_examples 'LOG lines for the duplicated task name in directories' do |  task_name, directories |

  # This example expects a variable named :file_contents to be defined
  # and to be able to respond to :match
  # Ex:
  #  it_behaves_like 'log line for duplicated task name in directores',  'shf:test:task0', ['2019_Q1', '2019_Q2', 'blorf'] do
  #           let(:log_contents) do
  #             subject.files_with_tasks_to_run
  #             File.read(logfilepath)
  #           end
  #         end
  #
  directories.each do | directory |
    it "error logged for task name #{task_name} in directory #{directory}"  do
      expect(log_contents).to match(/\[error\] Duplicate task name\! Task named '#{task_name}' in the file (.*)(\/*)#{directory}(\/+)(.*)\.rake\: This task is a duplicate: more than 1 task to be run has this task name\. This task cannot be run\. Rename it or the other duplicate\(s\)\./)
    end
  end

end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------


RSpec.describe OneTimeTasker::TasksFinder, type: :model do

  include_context 'create logger'
  include_context 'simple rake task files maker'

  let(:logfilepath) { LogfileNamer.name_for(described_class) }


  before(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)

    @tasks_directory = Dir.mktmpdir('test-onetime_rake_files')
    subject.tasks_directory = @tasks_directory
  end

  after(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)
  end


  describe 'files_with_tasks_to_run' do


    it 'returns a Hash with each key = full rake file path and value = the list of tasks to run in that file' do

      # Create 2 .rake files in the 2019_Q2 directory (task0, task1)
      q2_rakefiles = make_simple_rakefiles_under_subdir(subject.tasks_directory, '2019_Q2', 2, start_num: 0)

      # Create 1 .rake file in a subdirectory named 'blorfo' (task2)
      blorfo_rakefiles = make_simple_rakefiles_under_subdir(subject.tasks_directory, 'blorfo', start_num: 2)
      blorfo_rakefile  = blorfo_rakefiles.first

      # add 2 other tasks to blorfo_rakefile
      task3_in_file = simple_rake_task('task3_in_the_blorfo_rake_file')
      task4_in_file = simple_rake_task('task4_in_the_blorfo_rake_file')
      File.open(blorfo_rakefile, 'a') do |f|
        f.puts task3_in_file
        f.puts task4_in_file
      end

      q2_and_blorfo_files = q2_rakefiles.concat( blorfo_rakefiles)

      # Record blorfo/test2.rake task0 as having been attempted but _failed_
      create(:one_time_tasker_task_attempt, :unsuccessful_task, task_name: 'shf:test:task2')

      # Record blorfo/test2.rake task3_in_the_blorfo_rake_file as having been attempted and succeeded
      create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task3_in_the_blorfo_rake_file')


      actual_files_with_tasks = subject.files_with_tasks_to_run

      # Rake files that have tasks to run:
      expect(actual_files_with_tasks.keys).to match_array(q2_and_blorfo_files)


      # Tasks to be run:

      # one task in 2019_Q2/test1.rake
      expect(actual_files_with_tasks[q2_rakefiles.first]).to match_array(['shf:test:task0'])

      # one task in 2019_Q2/test2.rake
      expect(actual_files_with_tasks[q2_rakefiles.second]).to match_array(['shf:test:task1'])

      # two tasks in the blorfo_rakefile should be run (task3_in_the_blorfo_rake_file was already run successfully)
      expect(actual_files_with_tasks[blorfo_rakefile]).to match_array(['shf:test:task2', 'shf:test:task4_in_the_blorfo_rake_file'])
    end


    context 'is empty if' do

      it 'no rake files found' do
        expect(subject.files_with_tasks_to_run).to be_empty
      end

      it 'no tasks in the rake files' do

        # create 3 empty .rake files
        3.times do |i|
          filepath_created = File.join(File.absolute_path(subject.tasks_directory), "task_#{i}.rake")
          File.open(filepath_created, 'w') do |f|
            f.puts ''
          end
        end

        expect(subject.files_with_tasks_to_run).to be_empty
      end

      it 'all tasks have been successfully run' do

        # Create 3 .rake files in the 2019_Q2 directory
        make_simple_rakefiles_under_subdir(subject.tasks_directory, '2019_Q2', 3)

        # Record task0, task1, and task2 as already been run successfully
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task0')
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task1')
        create(:one_time_tasker_task_attempt, :successful_task, task_name: 'shf:test:task2')

        expect(subject.files_with_tasks_to_run).to be_empty
      end
    end


    describe 'duplicates' do

      before(:each) do
        allow(subject).to receive(:files_with_all_tasks_to_run).and_return(files_and_tasks)
      end

      let(:files_with_tasks_after_duplicates_removed) { subject.files_with_tasks_to_run }


      context 'no duplicates (files and tasks after duplicates removed == original files and tasks)' do

        let(:files_and_tasks) {
          {
            File.absolute_path(File.join(subject.tasks_directory, '2019_Q1', 'test.rake')) => ['shf:test:task0_2019Q1', 'shf:test:task1_2019Q1'],
            File.absolute_path(File.join(subject.tasks_directory, '2019_Q2', 'test.rake')) => ['shf:test:task0_2019Q2'],
            File.absolute_path(File.join(subject.tasks_directory, 'blorf', 'test.rake'))   => ['shf:test:task0_blorf', 'shf:test:task1_blorf', 'shf:test:task3_blorf']
          }
        }

        it_behaves_like 'it changes FailedTaskAttempts and has SuccessfulTaskAttempts', 0, 0


        it 'no duplicates are logged' do

          subject.files_with_tasks_to_run

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).not_to match(/\[error\] Duplicate task name! Task named (.*): This task is a duplicate\.  More than 1 task to be run has this task name\. This task cannot be run as a duplicate; rename it or the other duplicate\(s\)\./)
        end


        it 'the list of tasks is the same after (no) duplicates are removed' do
          expect(files_with_tasks_after_duplicates_removed.keys).to match_array(files_and_tasks.keys)
          expect(files_with_tasks_after_duplicates_removed).to eq files_and_tasks
        end
      end


      context 'one taskname is duplicated 3 times' do

        let(:files_and_tasks) {
          duplicated_task_name = 'shf:test:task0'
          {
              File.absolute_path(File.join(subject.tasks_directory, '2019_Q1', 'test.rake')) => [duplicated_task_name],
              File.absolute_path(File.join(subject.tasks_directory, '2019_Q2', 'test.rake')) => [duplicated_task_name],
              File.absolute_path(File.join(subject.tasks_directory, 'blorf', 'test.rake'))   => [duplicated_task_name, 'shf:test:not_a_duplicate']
          }
        }

        #before(:each) {  subject.files_with_tasks_to_run }

        it_behaves_like 'it changes FailedTaskAttempts and has SuccessfulTaskAttempts', 3, 0

        it_behaves_like 'LOG lines for the duplicated task name in directories',  'shf:test:task0', ['2019_Q1', '2019_Q2', 'blorf'] do
          let(:log_contents) do
            subject.files_with_tasks_to_run
            File.read(logfilepath)
          end
        end

        it 'removes the duplicates from the list of tasks to be run' do

          blorf_dir = File.absolute_path(File.join(subject.tasks_directory, 'blorf', 'test.rake'))

          expect(files_with_tasks_after_duplicates_removed.keys).to match_array([blorf_dir])
          expect(files_with_tasks_after_duplicates_removed[blorf_dir]).to match_array(['shf:test:not_a_duplicate'])
        end
      end


      context 'multiple tasknames are duplicated' do

        let(:duplicated_task_name0) { 'shf:test:dup0' }
        let(:duplicated_task_name1) { 'shf:test:dup1' }
        let(:duplicated_task_name2) { 'shf:test:dup2' }

        let(:files_and_tasks) {
          {
              File.absolute_path(File.join(subject.tasks_directory, '2019_Q1', 'test.rake')) => [duplicated_task_name0, duplicated_task_name1, duplicated_task_name2],
              File.absolute_path(File.join(subject.tasks_directory, '2019_Q2', 'test.rake')) => [duplicated_task_name0],
              File.absolute_path(File.join(subject.tasks_directory, 'blorf', 'test.rake'))   => [duplicated_task_name0, 'shf:test:blorf0',duplicated_task_name1, 'shf:test:blorf1'],
              File.absolute_path(File.join(subject.tasks_directory, 'test.rake'))   => ['shf:test:top_level0', 'shf:test:top_level1', duplicated_task_name2, 'shf:test:top_level2']
          }
        }

        let(:base_dir) { subject.tasks_directory }


        it_behaves_like 'it changes FailedTaskAttempts and has SuccessfulTaskAttempts', 7, 0

        it_behaves_like 'LOG lines for the duplicated task name in directories',  'shf:test:dup0', ['2019_Q1', '2019_Q2', 'blorf'] do
          let(:log_contents) do
            subject.files_with_tasks_to_run
            File.read(logfilepath)
          end
        end

        it_behaves_like 'LOG lines for the duplicated task name in directories',  'shf:test:dup1', ['2019_Q1', 'blorf'] do
          let(:log_contents) do
            subject.files_with_tasks_to_run
            File.read(logfilepath)
          end
        end

        it_behaves_like 'LOG lines for the duplicated task name in directories',  'shf:test:dup2', ['2019_Q1', @tasks_directory] do
          let(:log_contents) do
            subject.files_with_tasks_to_run
            File.read(logfilepath)
          end

        end


        it 'removes the duplicates from the list of tasks to be run' do
          tasks_dir_rakefile = File.absolute_path(File.join(subject.tasks_directory, 'test.rake'))
          blorf_dir_rakefile= File.absolute_path(File.join(subject.tasks_directory, 'blorf', 'test.rake'))

          expect(files_with_tasks_after_duplicates_removed.keys).to match_array([tasks_dir_rakefile, blorf_dir_rakefile])

          expect(files_with_tasks_after_duplicates_removed[tasks_dir_rakefile]).to match_array(['shf:test:top_level0', 'shf:test:top_level1', 'shf:test:top_level2'])
          expect(files_with_tasks_after_duplicates_removed[blorf_dir_rakefile]).to match_array(['shf:test:blorf0', 'shf:test:blorf1'])
        end

      end
    end

  end


  describe 'onetime_rake_files' do

    it 'empty if the onetime path does not exist' do
      subject.tasks_directory = 'blorf'
      expect(subject.onetime_rake_files).to be_empty
    end

    it 'empty if no .rake files' do
      expect(subject.onetime_rake_files).to be_empty
    end

    it 'only returns .rake files' do

      # Create 1 .rake file in the directory
      make_simple_rakefiles_under_subdir(subject.tasks_directory, '.', 1)

      # Create 3 .rake files in the 'blorfo' subdirectory
      make_simple_rakefiles_under_subdir(subject.tasks_directory, 'blorfo', 3)

      # Create 2 .rake files in the 'flurb' subdirectory
      make_simple_rakefiles_under_subdir(subject.tasks_directory, 'flurb', 2)

      # Create some files that do not have a .rake extension
      not_rake_files = ['blorf.rake.txt', 'blorf.txt', 'blorf', 'rake']
      not_rake_files.each do |not_a_rake_file|
        filepath_created = File.join(File.absolute_path(subject.tasks_directory), not_a_rake_file)
        File.open(filepath_created, 'w') do |f|
          f.puts 'blorf is here'
        end
      end

      expect(subject.onetime_rake_files).to match_array(["test0.rake", "blorfo/test0.rake", "blorfo/test1.rake", "blorfo/test2.rake", "flurb/test0.rake", "flurb/test1.rake"])
    end

    it 'ignores a file a file named .rake (the extension only)' do

      # Create a file that is named ".rake"  It wil
      filepath_created = File.join(File.absolute_path(subject.tasks_directory), '.rake')
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
        expect(described_class.default_tasks_directory).to eq File.join(Rails.root, 'lib', 'tasks', 'one_time')
        expect(subject.default_tasks_directory).to eq described_class.default_tasks_directory
      end
    end


    it 'use a block (e.g. in initializer file)' do
      temp_task_dir_path = Dir.mktmpdir('test-task-dir-path')
      make_simple_rakefiles_under_subdir(temp_task_dir_path, '.', 2)

      OneTimeTasker::TasksFinder.configure do | config |
          config.tasks_directory = temp_task_dir_path
      end

      expect(subject.onetime_rake_files).to match_array(['test0.rake', 'test1.rake'])
    end


    it 'manually set the tasks directory to use' do
      temp_task_dir_path = Dir.mktmpdir('test-task-dir-path')
      make_simple_rakefiles_under_subdir(temp_task_dir_path, '.', 2)

      subject.tasks_directory = temp_task_dir_path

      expect(subject.onetime_rake_files).to match_array(['test0.rake', 'test1.rake'])
    end

  end

end
