require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')

require 'shared_examples/backup_maker_target_filename_with_default_spec'


RSpec.describe ShfBackupMakers::CodeBackupMaker do

  describe 'Unit tests' do

    it 'base_filename = current.tar' do
      expect(subject.base_filename).to eq 'current.tar'
    end

    it 'default sources = [/var/www/shf/current/]' do
      expect(subject.backup_sources).to eq ['/var/www/shf/current/']
    end


    describe 'backup' do

      it 'will not fail if no sources specified (since default should have files in the directory)' do

        source_dir = Dir.mktmpdir('backup-source-dir')
        source_files = []
        3.times do |i|
          fn = File.join(source_dir, "source-#{i}.txt")
          File.open(fn, 'w') { |f| f.puts "blorf" }
          source_files << fn
        end

        allow(subject).to receive(:default_sources).and_return(source_files)

        target_backup_fn = 'target.bak'
        expect { subject.backup(target: target_backup_fn) }.not_to raise_error(ShfConditionError::BackupCommandNotSuccessfulError, /tar: no files or directories specified/)
        File.delete(target_backup_fn)
      end
    end
  end
end
