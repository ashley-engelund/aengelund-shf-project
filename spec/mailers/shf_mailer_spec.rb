require 'rails_helper'

require 'email_spec'
require 'email_spec/rspec'


RSpec.describe ShfMailer, type: :mailer do

  include Devise::Mailers::Helpers


  TEST_TEMPLATE = 'empty_template'


  describe '#mailgun_client' do

    let(:mg_client) { subject.mailgun_client }

    it 'is never nil' do
      expect(mg_client).not_to be_nil
    end

    it 'is a Mailgun::Client.new' do
      expect(mg_client).to be_an_instance_of(Mailgun::Client)
    end

  end


  describe '#message_builder' do

    let(:mg_builder) { subject.message_builder }

    it 'is never nil' do
      expect(mg_builder).not_to be_nil
    end

    it 'is a Mailgun::MessageBuilder.new' do
      expect(mg_builder).to be_an_instance_of(Mailgun::MessageBuilder)
    end

    it "default from address is ENV['SHF_SENDER_EMAIL']" do
      expect(mg_builder.message[:from]).to eq([ENV['SHF_SENDER_EMAIL']])
    end


  end


  describe '#domain' do

    it 'can be nil (which should then rightly mean an error response from Mailgun)' do

      stub_const('ENV', ENV.to_hash)
      ENV.delete('MAILGUN_DOMAIN')

      expect(subject.domain).to be_nil
    end


    it 'can be some value (not nil)' do
      stub_const('ENV', ENV.to_hash.merge('MAILGUN_DOMAIN' => 'blorf.com'))
      expect(subject.domain).to eq 'blorf.com'
    end


  end


  describe 'content is correct' do

    before(:all) do
      @recipient = create(:user)
      @email = ShfMailer.new.reset_password_instructions(@recipient, :reset_password_instructions)
    end


    it "should be set to be delivered to the email passed in" do
      expect(@email).to deliver_to(@recipient.email)
    end


    it "should have the correct subject" do
      initialize_from_record(@recipient) # required to use Devise::Mailers::Helpers subject_for
      expect(@email).to have_subject(subject_for(:reset_password_instructions))
    end

    it "default from address is ENV['SHF_NOREPLY_EMAIL']" do
      expect(@email).to be_delivered_from(ENV['SHF_NOREPLY_EMAIL'])
    end

    it 'greeting uses first and last name' do
      expect(@email).to have_body_text(I18n.t('shf_mailer.greeting', greeting_name: @recipient.full_name))
    end


    describe 'signoff section' do

      it 'should have a signoff' do
        expect(@email).to have_body_text(I18n.t('shf_mailer.shf_signoff'))
      end


      describe 'signature' do

        it 'should have a signature' do
          expect(@email).to have_body_text(I18n.t('shf_mailer.shf_signature'))
        end

        it 'should have a link to the site - text format' do
          expect(@email.text_part.body).to match(/#{I18n.t('shf_mailer.shf_signature')}\s+#{root_url}/)
        end

        it 'should have a link to the site - html format' do
          expect(@email.html_part.body.to_s).to match(/<div id='signature'>\s*(.)*\s*<a(.)*href="#{root_url}">#{I18n.t('shf_mailer.shf_signature_url')}<\/a>\s*<\/div>/)
        end

      end

    end


    it 'text in the footer ' do
      expect(@email).to have_body_text(I18n.t('shf_mailer.footer.text'))
    end

  end


  it 'language is set' do
    #pending 'need to change locale and ensure the right language is in the email created'
  end


  describe 'use :mailgun delivery method' do

    before(:all) { Rails.configuration.action_mailer.delivery_method = :mailgun }

    before(:each) { subject.mailgun_client.enable_test_mode! }

    after(:each) { subject.mailgun_client.disable_test_mode! }


    describe 'simple test email' do

      let(:test_email_response) {
        result = subject.mail(to: 'recipient@example.com', subject: "Test email from SHF", template_name: TEST_TEMPLATE)
        result.deliver
      }

      it 'is delivered' do
        expect(test_email_response.message_id).not_to be_nil

        delivered = ShfMailer.deliveries
        expect(delivered.count).to eq 1
        expect(test_email_response[:message_id]).to eq(delivered.first[:message_id])
      end

    end


    describe 'can send with attachments' do

      let(:test_email_response) {

        attachment1 = {
            content: file_fixture('diploma.pdf'),
            mime_type: 'application/pdf',
        }
        attachment2 = {
            content: file_fixture('microsoft-word.docx'),
            mime_type: 'application/docx',
        }

        result = subject.mail(to: 'recipient@example.com',
                              subject: 'Test email with attachment',
                              template_name: TEST_TEMPLATE,
                              attachments: [attachment1, attachment2])
        result.deliver
      }


      it 'is delivered' do
        expect(test_email_response.message_id).not_to be_nil

        delivered = ShfMailer.deliveries
        expect(delivered.count).to eq 1
        expect(test_email_response[:message_id]).to eq(delivered.first[:message_id])
      end

    end


  end

end
