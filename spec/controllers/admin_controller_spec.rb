require 'rails_helper'


RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, :type => :controller
end


RSpec.describe AdminController, type: :controller do

  include Warden::Test::Helpers

  include Devise::Test::ControllerHelpers

  # this will bypass Pundit policy access checks so logging in is not necessary
  before(:each) { Warden.test_mode! }

  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }

  let(:csv_header) { out_str = ''
  out_str << "'#{I18n.t('activerecord.attributes.membership_application.first_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.membership_application.last_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.membership_application.contact_email').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.membership_application.state').strip}'\n"
  out_str }


  describe '#export_ankosan_csv' do

    describe 'logged in as admin' do

      it 'content type is text/csv' do

        post :export_ansokan_csv

        expect(response.content_type).to eq 'text/plain'

      end


      describe 'with 0 membership applications' do

        it 'no membership applications has just the header' do

          post :export_ansokan_csv

          expect(response.body).to eq csv_header

        end

      end

      describe 'with 1 app for each state' do

        it 'includes all applications' do

          result_str = ''

          # create 1 application in each state
          MembershipApplication.aasm.states.each do |app_state|

            u = FactoryGirl.create(:user, email: "#{app_state.name.to_s}@example.com")

            m = FactoryGirl.create :membership_application,
                                   first_name: "First#{app_state.name.to_s}",
                                   last_name: "Last#{app_state.name.to_s}",
                                   contact_email: "#{app_state.name.to_s}@example.com",
                                   state: app_state.name,
                                   user: u
            result_str << "#{m.first_name},#{m.last_name},#{m.contact_email},"+ I18n.t("membership_applications.state.#{app_state.name}") +"\n"
          end

          post :export_ansokan_csv

          expect(response.body).to match result_str

        end


      end

    end

  end


end
