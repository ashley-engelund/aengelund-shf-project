# Stub the most expensive Paperclip methods
#
# This stubs the system calls that Paperclip does to post-process an attachment --
#   like create other styles of it (thumbnails, etc)
#
# This does _not_ stub calls 'file' to check the MIME type or to link or delete the attachment file.

RSpec.shared_context 'stub Paperclip methods' do

  before(:each) do

    allow_any_instance_of(Paperclip::Processor).to receive(:convert)
    allow_any_instance_of(Paperclip::Processor).to receive(:identify)
    allow_any_instance_of(Paperclip::Attachment).to receive(:post_process_file)

    # stub calls to run commands
    allow(Paperclip).to receive(:run)
                            .with('convert', any_args)
                            .and_return(true)

    allow(Paperclip).to receive(:run)
                            .with('identify', any_args)
                            .and_return("100x100")

    allow(Paperclip).to receive(:run)
                            .with('file', any_args)
                            .and_return("image/png; charset=binary")
  end

end
