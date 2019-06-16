# Specs for AbstractBackupMaker and subclasses

require 'rails_helper'

require_relative File.join(Rails.root, 'app/models/conditions_response/backup')


RSpec.describe AbstractBackupMaker do

  describe 'Unit tests' do

    it 'default sources = []' do
      expect(subject.backup_sources).to eq []
    end

    it 'default backup target base filename = backup-<class name>-<DateTime.current>.tar' do
      expect(subject.backup_target_filebase).to match(/backup-AbstractBackupMaker\.tar/)
    end

    describe 'shell_cmd' do

      it 'raises an error if one was encountered' do
        allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT, 'blorfo')
        expect { subject.shell_cmd('blorfo') }.to raise_error(Errno::ENOENT, 'No such file or directory - blorfo')
      end

      it 'raises BackupCommandNotSuccessfulError and shows the command, status, stdout, and stderr if it was not successful' do
        allow(Open3).to receive(:capture3).and_return(['output string', 'error string', nil])
        expect { subject.shell_cmd('blorfo') }.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError,
                                                              "Backup Command Failed: blorfo. return status:   Error: error string  Output: output string")
      end

    end

    it 'backup raises NoMethodError Subclasses must define' do
      expect { subject.backup }.to raise_error(NoMethodError, 'Subclass must define the backup method')
    end


  end

end


RSpec.describe FilesBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { FilesBackupMaker.new }

    it 'default backup target base filename = backup-FilesBackupMaker.tar' do
      expect(subject.backup_target_filebase).to eq 'backup-FilesBackupMaker.tar'
    end


    describe '#backup' do

      it 'uses #shell_cmd to create a tar in the destination directory with all entries in sources using tar -chzf}' do

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_sourcefn1 = File.open(File.join(temp_backup_sourcedir, 'faux-codefile.rb'), 'w').path
        temp_backup_sourcefn2 = File.open(File.join(temp_backup_sourcedir, 'faux-otherfile.rb'), 'w').path
        temp_subdir = File.join(temp_backup_sourcedir, 'subdir')
        FileUtils.mkdir_p(temp_subdir)
        temp_backup_in_subdir_fn = File.open(File.join(temp_backup_sourcedir, 'subdir', 'faux-codefile2.rb'), 'w').path

        temp_backup_sourcedir2 = Dir.mktmpdir('faux-code-dir2')
        temp_backup_source2fn1 = File.open(File.join(temp_backup_sourcedir2, 'dir2-faux-codefile.rb'), 'w').path

        temp_backup_target = File.join(Dir.mktmpdir('temp-files-dir'), 'files_backup_fn.zzkx')

        files_backup = described_class.new(backup_target_filebase: temp_backup_target,
                                           backup_sources: [temp_backup_sourcedir,
                                                            temp_backup_source2fn1])
        files_backup.backup


        expect(File.exist?(temp_backup_target)).to be_truthy

        # could also use the Gem::Package verify_entry method to verify each tar entry
        backup_file_list = %x<tar --list --file=#{temp_backup_target}>
        backup_file_list.gsub!(/\n/, ' ')
        backup_files = backup_file_list.split(' ')

        # tar will remove leading "/" from source file names, so remove the leading "/"
        expected = [temp_backup_sourcefn1.gsub(/^\//, ''),
                    temp_backup_sourcefn2.gsub(/^\//, ''),
                    temp_backup_in_subdir_fn.gsub(/^\//, ''),
                    "#{temp_subdir.gsub(/^\//, '')}/",
                    "#{temp_backup_sourcedir.gsub(/^\//, '')}/",
                    temp_backup_source2fn1.gsub(/^\//, '')]

        expect(backup_files).to match_array(expected)
      end

    end

  end
end


RSpec.describe CodeBackupMaker do

  describe 'Unit tests' do

    it 'default backup target base filename = current.tar' do
      expect(subject.backup_target_filebase).to eq 'current.tar'
    end

    it 'default sources = [CODE_ROOT_DIRECTORY]' do
      expect(subject.backup_sources).to eq ['/var/www/shf/current/']
    end

  end
end


RSpec.describe DBBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { DBBackupMaker.new }

    it 'default backup target base filename = db_backup.sql' do
      expect(subject.backup_target_filebase).to eq 'db_backup.sql'
    end

    it 'default sources = [DB_NAME]' do
      expect(subject.backup_sources).to eq ['shf_project_production']
    end


    describe '#backup' do

      describe 'dumps the dbs in sources and creates 1 backup gzipped file' do

        before(:each) { @temp_dir = Dir.mktmpdir('db-backup-source-dir') }

        it 'using default target' do

          new_db_backup = described_class.new(backup_sources: ['this1', 'that2'])

          expected_backup_fname =  'db_backup.sql'
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup()

          expect(File.exist?(expected_backup_fname)).to be_truthy
          File.delete(expected_backup_fname)
        end

        it 'given a filename to use as the target' do

          temp_backup_target = File.join(@temp_dir, 'db_dumped.sql')

          new_db_backup = described_class.new(backup_target_filebase: temp_backup_target,
                                              backup_sources: ['this1', 'that2'])

          expected_backup_fname = temp_backup_target
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup
          expect(File.exist?(expected_backup_fname)).to be_truthy
        end
      end
    end

  end
end
