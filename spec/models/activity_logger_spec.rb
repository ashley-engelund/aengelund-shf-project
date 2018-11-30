require 'rails_helper'

# ===========================================================================
#  shared examples

RSpec.shared_examples 'it creates an ActivityLogger log' do

  it 'creates the ActivityLogger log instance' do
    activity_log
    expect(File).to exist(streamname)
    expect(activity_log).to be_an_instance_of(ActivityLogger)
  end

end


# ===========================================================================

RSpec.describe ActivityLogger do

  LOGDIR_PREFIX = 'alspec'
  LOGNAME = 'testlog.log'

  # If everything is written to stdout, we can't test writing to log files.
  # So be sure we don't have ENV['RAILS_LOG_TO_STDOUT'] defined during the tests.
  before(:all) do
    if ENV.has_key? 'RAILS_LOG_TO_STDOUT'
      @env_has_r_to_stdout = true
      @env_r_to_stdout_value = ENV.delete('RAILS_LOG_TO_STDOUT')
    end
  end

  after(:all) do
    if @env_has_r_to_stdout
      ENV['RAILS_LOG_TO_STDOUT'] = @env_r_to_stdout_value
    end
  end

  describe 'log file' do

    let(:filepath) { File.join( Dir.mktmpdir(LOGDIR_PREFIX), LOGNAME) }
    let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }


    before(:each) do
      File.delete(filepath) if File.file?(filepath)
    end

    context 'open without a block' do

      it_behaves_like 'it creates an ActivityLogger log' do
        let(:streamname) {filepath}
        let(:activity_log) { log }
      end

      it 'records message to log file' do
        log.record('info', 'this is a test message')
        expect(File.read(filepath))
            .to include '[TEST] [open] [info] this is a test message'
      end

    end # context 'open without a block'


    context 'open with a block' do

      it 'creates log file' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |_log|
          expect(File).to exist(filepath)
        end
      end
      it 'returns instance of ActivityLogger' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |log|
          expect(log).to be_an_instance_of(ActivityLogger)
        end
      end
      it 'records message to log file' do
        ActivityLogger.open(filepath, 'TEST', 'open', false) do |log|
          log.record('info', 'this is another test message')
          expect(File.read(filepath))
              .to include '[TEST] [open] [info] this is another test message'
        end
      end

    end  # context 'open with a block'

  end #  describe 'log file'


  context 'using $stdout as the log' do

    context 'open without a block' do

      it_behaves_like 'it creates an ActivityLogger log' do
        let(:streamname)  { $stdout }
        let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }
      end

      it 'records message to $stdout' do
        expect do
          logstream =  $stdout
          log = ActivityLogger.open(logstream, 'TEST', 'open', false)
          log # to open it
          log.record('info', 'this is a test message')
        end.to output(/\[TEST\] \[open\] \[info\] this is a test message/).to_stdout

      end

    end # context 'open without a block'


    context 'open with a block' do

      let(:streamname)  { $stdout }
      let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }

      it 'creates log file' do
        ActivityLogger.open(streamname, 'TEST', 'open', false) do |_log|
          expect(File).to exist(streamname)
        end
      end

      it 'returns instance of ActivityLogger' do
        ActivityLogger.open(streamname, 'TEST', 'open', false) do |log|
          expect(log).to be_an_instance_of(ActivityLogger)
        end
      end

      it 'records message to $stdout' do
          expect do
            logstream =  $stdout
            ActivityLogger.open(logstream, 'TEST', 'open', false) do |log|
              log # to open it
              log.record('info', 'this is another test message')
            end
          end.to output(/\[TEST\] \[open\] \[info\] this is another test message/).to_stdout
      end

    end # context 'open with a block'

  end # context 'using $stdout as the log'


  context "using $stderr as the log" do

    context 'open without a block' do

      it_behaves_like 'it creates an ActivityLogger log' do
        let(:streamname)  { $stderr }
        let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }
      end

      it "records message to $stderr" do
        expect do
          logstream =  $stderr
          log = ActivityLogger.open(logstream, 'TEST', 'open', false)
          log # to open it
          log.record('info', 'this is a test message')
        end.to output(/\[TEST\] \[open\] \[info\] this is a test message/).to_stderr

      end

    end # context 'open without a block'


    context 'open with a block' do

      let(:streamname)  { $stderr }
      let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }

      it 'creates log file' do
        ActivityLogger.open(streamname, 'TEST', 'open', false) do |_log|
          expect(File).to exist(streamname)
        end
      end

      it 'returns instance of ActivityLogger' do
        ActivityLogger.open(streamname, 'TEST', 'open', false) do |log|
          expect(log).to be_an_instance_of(ActivityLogger)
        end
      end

      it "records message to $stderr" do
        expect do
          logstream =  $stderr
          ActivityLogger.open(logstream, 'TEST', 'open', false) do |log|
            log # to open it
            log.record('info', 'this is another test message')
          end
        end.to output(/\[TEST\] \[open\] \[info\] this is another test message/).to_stderr
      end

    end # context 'open with a block'

  end # context 'using $stderr as the log'


  describe '#verified_output_stream' do

    context "always writes to $stdout if ENV.has_key? 'RAILS_LOG_TO_STDOUT' " do

      let(:filepath) { File.join( Dir.mktmpdir(LOGDIR_PREFIX), LOGNAME) }
      let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }


      before(:each) do
        File.delete(filepath) if File.file?(filepath)
      end


      it "ENV['RAILS_LOG_TO_STDOUT'] is present" do
        orig_has_r_to_stdout = true

        unless ENV.has_key? 'RAILS_LOG_TO_STDOUT'
          orig_has_r_to_stdout = false
          ENV['RAILS_LOG_TO_STDOUT'] = '1'
        end

        # expect info to write to stdout
        expect do
          log
          log.record('info', 'this is a test message')
        end.to output(/\[TEST\] \[open\] \[info\] this is a test message/).to_stdout

        # expect the log file not to  be created
        expect(File).not_to exist(filepath)

        unless orig_has_r_to_stdout
          ENV.delete('RAILS_LOG_TO_STDOUT')
        end
      end


      it "ENV['RAILS_LOG_TO_STDOUT'] is not present" do
        orig_has_r_to_stdout = false

        if ENV.has_key? 'RAILS_LOG_TO_STDOUT'
          orig_has_r_to_stdout = true
          orig_r_to_stdout_value = ENV.delete('RAILS_LOG_TO_STDOUT')
        end

        # expect nothing to be written to stdout
        expect do
          log # to open it
          log.record('info', 'this is a test message')
        end.not_to output(/\[TEST\] \[open\] \[info\] this is a test message/).to_stdout

        # expect the log file to change or be created
        expect(File).to exist(filepath)

        if orig_has_r_to_stdout
          ENV['RAILS_LOG_TO_STDOUT'] = orig_r_to_stdout_value
        end
      end


    end # context "always writes to $stdout if ENV['RAILS_LOG_TO_STDOUT'].present?" do

    context 'directory does not exist' do

      it 'cannot create directory, returns $stdout' do

        nonexistant_dirname = Dir::Tmpname.create(LOGDIR_PREFIX) { |dirname| dirname }
        unverified_filename = File.join(nonexistant_dirname, LOGNAME)

        expect(File.exists?(nonexistant_dirname)).to be_falsey

        allow(Dir).to receive(:mkdir).and_raise(IOError)

        verified_output = ActivityLogger.verified_output_stream(unverified_filename)
        expect(verified_output).to eq $stdout

      end

      it 'cannot create a writeable directory, returns $stdout' do

        nonexistant_dirname = Dir::Tmpname.create(LOGDIR_PREFIX) { |dirname| dirname }
        unverified_filename = File.join(nonexistant_dirname, LOGNAME)

        expect(File.exists?(nonexistant_dirname)).to be_falsey

        original_mkdir = Dir.method(:mkdir)

        allow(Dir).to receive(:mkdir) do
            original_mkdir.call(nonexistant_dirname)
            File.chmod(0444, nonexistant_dirname) # make it read only
            nonexistant_dirname
        end

        verified_output = ActivityLogger.verified_output_stream(unverified_filename)
        expect(verified_output).to eq $stdout

      end

      it 'if it can create a directory and it is writable, returns the directory' do

        nonexistant_dirname = Dir::Tmpname.create(LOGDIR_PREFIX) { |dirname| dirname }
        unverified_filename = File.join(nonexistant_dirname, LOGNAME)

        expect(File.exists? nonexistant_dirname).to be_falsey

        verified_output = ActivityLogger.verified_output_stream(unverified_filename)
        expect(verified_output).to eq unverified_filename

        verified_dir = File.dirname(verified_output)
        expect(File.exists?(verified_dir)).to be_truthy
        expect(File.writable?(verified_dir)).to be_truthy

      end

    end # context log directory does not exist


    context 'directory is read only' do

      it 'returns $stdout as the verified output' do

        readonly_dir = Dir.mktmpdir(LOGDIR_PREFIX)
        File.chmod(0444, readonly_dir)  # make it read only

        unverified_filename = File.join(readonly_dir, LOGNAME)

        expect(File.exists? readonly_dir).to be_truthy
        expect(File.writable? readonly_dir).to be_falsey

        verified_output = ActivityLogger.verified_output_stream(unverified_filename)
        expect(verified_output).to eq $stdout

      end

    end

    it 'directory exists and is writable, returns the original filename (and path)' do

      readonly_dir = Dir.mktmpdir(LOGDIR_PREFIX)

      unverified_filename = File.join(readonly_dir, LOGNAME)

      expect(File.exists? readonly_dir).to be_truthy
      expect(File.writable? readonly_dir).to be_truthy

      verified_output = ActivityLogger.verified_output_stream(unverified_filename)
      expect(verified_output).to eq unverified_filename
    end


    context 'is a standard output stream ($stdout | $stderr)' do

      it 'returns $stdout if unverfied is $stdout' do
        expect(ActivityLogger.verified_output_stream($stdout)).to eq $stdout
      end

      it 'returns $stderr if unverified is $stderr' do
        expect(ActivityLogger.verified_output_stream($stderr)).to eq $stderr
      end

    end # context 'is a standard stream ($stdout | $stderr)' do

  end

end
