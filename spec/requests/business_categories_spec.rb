require 'rails_helper'

RSpec.describe "BusinessCategories", type: :request do
  describe "GET /business_categories" do
    it "works! (now write some real specs)" do
      get business_categories_path
      expect(response).to have_http_status(200)
    end
  end
end
