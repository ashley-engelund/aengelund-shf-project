require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')

require 'shared_examples/backup_maker_target_filename_with_default_spec'


RSpec.describe ShfBackupMakers::FileSetBackupMaker do


  describe 'Unit tests' do

    let(:backup_using_defaults) { ShfBackupMakers::FileSetBackupMaker.new('backup using defaults') }

    it 'base_filename = backup-FileSetBackupMaker.tar' do
      expect(subject.base_filename).to eq 'backup-FileSetBackupMaker.tar'
    end


    # FIXME does this stuff really go in the backup_spec #create File Maker ?
    # describe 'info provided by a Configuration' do
    #
    #   describe 'name (required)' do
    #
    #     it 'cannot be blank (there is no default)' do
    #       expect{described_class.new('')}.to raise_error(ShfConditionError::BackupConfigFileBackupMissingName)
    #     end
    #
    #     it 'can be read from a configuration' do
    #       pending
    #     end
    #   end
    #
    #   describe 'description (optional)' do
    #
    #     it 'default is empty String' do
    #       expect(subject.description).to eq ''
    #     end
    #
    #     it 'can be read from a configuration' do
    #       pending
    #     end
    #   end
    #
    #   describe 'base file name (optional)' do
    #
    #     it 'default is same as our parent class default' do
    #       pending
    #     end
    #
    #     it 'can be read from a configuration' do
    #       pending
    #     end
    #   end
    #
    # end


    describe '#backup' do

      it 'uses #shell_cmd to create a tar with all entries in sources using tar -chzf}' do

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_sourcefn1 = File.open(File.join(temp_backup_sourcedir, 'faux-codefile.rb'), 'w').path
        temp_backup_sourcefn2 = File.open(File.join(temp_backup_sourcedir, 'faux-otherfile.rb'), 'w').path
        temp_subdir = File.join(temp_backup_sourcedir, 'subdir')
        FileUtils.mkdir_p(temp_subdir)
        temp_backup_in_subdir_fn = File.open(File.join(temp_backup_sourcedir, 'subdir', 'faux-codefile2.rb'), 'w').path

        temp_backup_sourcedir2 = Dir.mktmpdir('faux-code-dir2')
        temp_backup_source2fn1 = File.open(File.join(temp_backup_sourcedir2, 'dir2-faux-codefile.rb'), 'w').path

        temp_backup_target = File.join(Dir.mktmpdir('temp-files-dir'), 'files_backup_fn.zzkx')

        files_backup = described_class.new(target_filename: temp_backup_target,
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


      it_behaves_like 'it takes a backup target filename, with default =', 'backup-FileSetBackupMaker.tar'


      describe 'source files for the backup' do

        it "default sources = [] (none)" do
          expect(subject).to receive(:shell_cmd)
                                 .with(/tar -chzf (.*) #{[].join(' ')}/)
          subject.backup
        end


        it 'can provide the sources' do

          files_backup = described_class.new

          source_dir = Dir.mktmpdir('backup-sources-dir')
          source_files = []
          3.times do |i|
            fn = File.join(source_dir, "source-#{i}.txt")
            File.open(fn, 'w') { |f| f.puts "blorf" }
            source_files << fn
          end

          expect(files_backup).to receive(:shell_cmd)
                                      .with(/tar -chzf (.*) #{source_files.join(' ')}/)
                                      .and_call_original

          backup_created = files_backup.backup(sources: source_files)
          puts "backup_created: #{backup_created}"

          expect(File.exist?(backup_created)).to be_truthy
          File.delete(backup_created)
        end

      end

      it 'will fail unless sources are provided (tar will fail with an empty list)' do
        expect { subject.backup }.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError, /tar/)
      end
    end

  end
end
