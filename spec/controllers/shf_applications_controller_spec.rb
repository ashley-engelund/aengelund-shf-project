require 'rails_helper'

require_relative 'controller_shared_examples'


RSpec.describe ShfApplicationsController, type: :controller do

  let(:admin) { create(:user, admin: true) }

  before(:each) { sign_in admin }

  context 'bad search parameters' do

    good_params = { "utf8" => "✓",
                    "q" => { "user_membership_number_in" => ["", "101"],
                             "user_last_name_in" => ["", "Claesson"],
                             "company_number_in" => ["", "1536355801"],
                             "state_in" => ["", "under_review"] },
                    "commit" => "Search",
                    "locale" => "en" }

    bad_params_and_test_desc = [
        { bad_params: { "utf8" => "✓",
                        "q" => { "user_membership_number_in" => { '0' => nil },
                                 "user_last_name_in" => { '0' => nil },
                                 "company_number_in" => { '0' => nil },
                                 "state_in" => { '0' => nil } },
                        "commit" => "Sök" },
          test_desc: 'empty search parameters (like Facebook might create when it sanitizes/processes a pasted URL)'
        }

    ]

    bad_params_and_test_desc.each do |bad_param_test|

      it_behaves_like 'it gracefully handles bad search parameters',
                      bad_param_test[:test_desc],
                      bad_param_test[:bad_params],
                      { controller: 'users', action: 'index' },
                      I18n.t('activerecord.models.user.other') do
        #sign_in admin
      end

    end

  end
end
