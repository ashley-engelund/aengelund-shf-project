require 'rails_helper'

class TempCompanyHelper
  include CompaniesHelper
end

RSpec.describe "map company partial: _map_company.html.haml" do

  let(:test_companies) do
    test_cos = []
    test_cos << create(:company)
  end

  EXPECTED_MARKERS = "var markers = [{\"latitude\":56.7422437,\"longitude\":12.7206453,"

  it "map markers are raw json (not escaped)" do

    render partial: 'companies/map_company.html.haml',
           locals: {markers: TempCompanyHelper.new.location_and_markers_for(test_companies, link_name: false)}

    expect(rendered).to include("var markers = [{\"latitude\":56.7422437,\"longitude\":12.7206453,")

    expect(rendered).not_to match %r(var markers =(.*)&quot;longitude) # should not have unescaped quote
  end

end
