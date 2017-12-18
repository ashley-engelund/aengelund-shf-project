require 'rails_helper'
require 'email_spec/rspec'


require File.join(__dir__, 'shared_email_tests')

require_relative './previews/member_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe MemberMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#membership_granted' do

    MEM_GRANTED_SCOPE = 'mailers.member_mailer.membership_granted'


    let(:accepted_app) { create(:shf_application, :accepted, user: test_user) }
    let(:email_sent) { MemberMailer.membership_granted(accepted_app.user) }


    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: MEM_GRANTED_SCOPE),
                    'user@example.com',
                    'Firstname Lastname' do
      let(:email_created) { email_sent }
    end

    it 'says your are now a member' do
      expect(email_sent).to have_body_text(I18n.t('message_text.now_a_member', scope: MEM_GRANTED_SCOPE))
    end

    it 'tells you what you need to do next' do
      expect(email_sent).to have_body_text(I18n.t('message_text.next_steps', scope: MEM_GRANTED_SCOPE))
    end

  end


  it 'has a previewer' do
    expect(MemberMailerPreview).to be
  end

end
