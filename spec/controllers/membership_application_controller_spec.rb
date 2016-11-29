require 'rails_helper'

RSpec.describe MembershipApplicationsController, type: :controller do

  include Devise::Test::ControllerHelpers

  describe 'upload files' do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:application) { create(:membership_application, user: application_owner) }


    it 'uploaded a file increases the number of files associated with a membership application by 1' do
      upload_file = fixture_file_upload(File.join('uploaded_files', 'image.png'), 'image/png')
      sign_in application_owner

      num_before_adding = application.uploaded_files.count
      expect {
        patch :update, params: {id: application.id,
                                'membership_application': {"first_name": application.first_name, 'last_name': application.last_name, 'company_number': application.company_number, 'contact_email': application.contact_email, 'phone_number': application.phone_number},
                                'uploaded_file': {'actual_files': [upload_file]}} }.to change { application.uploaded_files.count }.from(num_before_adding).to(num_before_adding + 1)

    end
  end

end
