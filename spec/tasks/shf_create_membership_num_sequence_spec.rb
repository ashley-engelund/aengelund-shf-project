require 'rails_helper'
require 'shared_context/rake'
require 'shared_context/activity_logger'


RSpec.describe 'shf shf:create_member_num_seq', type: :task do

  include_context 'rake'

  let(:drop_sequence_sql) { 'DROP SEQUENCE membership_number_seq;' }

  let(:log_filepath) { SHF_TASKS_LOG_FILE }

  before(:each) do
    File.delete(log_filepath) if File.file?(log_filepath)
  end


  describe 'sequence already exists' do


    it 'writes that it already exists to the log' do

      User.connection.execute(drop_sequence_sql)  # just to be sure

      create_sequence_sql = 'CREATE SEQUENCE IF NOT EXISTS membership_number_seq  START 101;'
      User.connection.execute(create_sequence_sql)

      already_exists_message = 'Sequence already exists. No need to create it.'

      # Preconditions
      # log should not have the already_exists_message (if it exists)
      expect(File.read(log_filepath)).not_to include(already_exists_message) if File.exist?(log_filepath)

      expect { subject.invoke }.not_to raise_error

      # log should now show the already_exists_message
      expect(File.read(log_filepath)).to include(already_exists_message) if File.exist?(log_filepath)
    end

  end


  describe 'sequence does not exist' do

    it 'creates it and checks the next sequence number, logs both actions' do

      User.connection.execute(drop_sequence_sql)

      seq_created_message = "Sequence created with: CREATE SEQUENCE IF NOT EXISTS membership_number_seq  START 101"

      # Preconditions
      # log should not have the seq_created_message (if it exists)
      expect(File.read(log_filepath)).not_to include(seq_created_message) if File.exist?(log_filepath)

      expect { subject.invoke }.not_to raise_error

      # log should now show the seq_created_message
      logfile = File.read(log_filepath)
      expect(logfile).to include(seq_created_message)
      expect(logfile).to include('next value = 101')
    end

  end

end
