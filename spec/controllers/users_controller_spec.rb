require 'rails_helper'

require_relative 'controller_shared_examples'


RSpec.describe UsersController, type: :controller do

  let(:admin) { create(:user, admin: true) }

  before(:each) { sign_in admin }

  context 'bad search parameters' do

    bad_params_and_test_desc = [
        { bad_params: { "utf8" => "✓", "q" => { "membership_number_in" => { this: {"0" => nil } },
                                                'email_cont' => { "0" => nil },
                                                'membership_filter' => { '0' => nil, "1" => "6" }
        },
                        "commit" => "Sök" },
          test_desc: 'empty search parameters (like Facebook might create when it sanitizes/processes a pasted URL)'
        },

    ]

    bad_params_and_test_desc.each do |bad_param_test|

      it_behaves_like 'it gracefully handles bad search parameters',
                      bad_param_test[:test_desc],
                      bad_param_test[:bad_params],
                      { controller: 'users',  action: 'index' },
                      I18n.t('activerecord.models.user.other') do
        #sign_in admin
      end

    end

  end
end
