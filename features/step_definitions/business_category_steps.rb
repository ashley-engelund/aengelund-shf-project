And(/^the following business categories exist$/) do |table|
  table.hashes.each do |business_category|
    FactoryGirl.create(:business_category, business_category)
  end
end


And(/^I navigate to the business category edit page for "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit edit_business_category_path(business_category)
end