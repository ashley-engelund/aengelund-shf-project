require 'rails_helper'

require_relative 'controller_shared_examples'


RSpec.describe CompaniesController, type: :controller do


  context 'bad search parameters' do

    bad_params_and_test_desc = [
        { bad_params: { "utf8" => "✓", "q" => { "business_categories_id_in" => { "0" => nil, },
                                                "addresses_region_id_in" => { "0" => nil, },
                                                "addresses_kommun_id_in" => { "0" => nil },
                                                "name_in" => { "0" => nil } },
                        "commit" => "Sök" },
          test_desc: 'empty search parameters (like Facebook might create when it sanitizes/processes a pasted URL)'
        },
        {
            bad_params: { "utf8" => "✓", "q" => { "business_categories_id_in" => { "0" => nil, "1" => "7", "2" => "6", "3" => "4", "4" => "2" },
                                                  "addresses_region_id_in" => { "0" => nil, "1" => "6" },
                                                  "addresses_kommun_id_in" => { "0" => nil },
                                                  "name_in" => { "0" => nil } } },
            test_desc: 'some empty search parameters, some with data'
        }
    ]

    bad_params_and_test_desc.each do |bad_param_test|

      it_behaves_like 'it gracefully handles bad search parameters',
                      bad_param_test[:test_desc],
                      bad_param_test[:bad_params],
                      {action: 'index'},
                      I18n.t('activerecord.models.company.other')

    end

  end

end
