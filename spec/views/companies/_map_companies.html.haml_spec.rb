require 'rails_helper'

class TempCompanyHelper
  include CompaniesHelper
end

RSpec.describe "company maps partial: _map_companies.html.haml" do

  let(:test_companies) do
    test_cos = []
    test_cos << create(:company)
  end

  EXPECTED_MARKERS = "var markers = [{\"latitude\":56.7422437,\"longitude\":12.7206453,"

  it "map markers are raw json (not escaped)" do

    render partial: 'companies/map_companies.html.haml',
           locals:  { markers:       TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                    link_name: false),
                      nearMeChecked: false }

    expect(rendered).to include(EXPECTED_MARKERS)
    expect(rendered).not_to match %r(let markers =(.*)&quot;longitude) # should not have unescaped quote
  end


=begin
  describe 'nearMeChecked' do

    it 'nearMeChecked can be undefined' do
      render partial: 'companies/map_companies.html.haml',
             locals:  { markers: TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                link_name: false) }
      expect(rendered).to include(EXPECTED_MARKERS)
    end


    context 'if nearMeChecked is not a Boolean, value is set to false' do
      # These just expect the view to not throw an error

      it '= 7' do
        render partial: 'companies/map_companies.html.haml',
               locals:  { markers:       TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                        link_name: false),
                          nearMeChecked: 7 }
        expect(rendered).to include(EXPECTED_MARKERS)
      end

      it 'nil' do
        render partial: 'companies/map_companies.html.haml',
               locals:  { markers:       TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                        link_name: false),
                          nearMeChecked: nil }
        expect(rendered).to include(EXPECTED_MARKERS)
      end

    end # context 'if nearMeChecked is not a Boolean, value is set to false' do

    it 'nearMeChecked can be true' do
      render partial: 'companies/map_companies.html.haml',
             locals:  { markers:       TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                      link_name: false),
                        nearMeChecked: true }
      expect(rendered).to include(EXPECTED_MARKERS)
    end

    it 'nearMeChecked can be false' do
      render partial: 'companies/map_companies.html.haml',
             locals:  { markers:       TempCompanyHelper.new.location_and_markers_for(test_companies,
                                                                                      link_name: false),
                        nearMeChecked: false }
      expect(rendered).to include(EXPECTED_MARKERS)
    end

  end # nearMeChecked
=end

end
