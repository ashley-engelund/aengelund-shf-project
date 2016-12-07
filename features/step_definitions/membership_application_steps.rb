And(/^the following applications exist:$/) do |table|
  table.hashes.each do |hash|

    if (user = User.find_by_email(hash['user_email']))
      FactoryGirl.create(:membership_application, hash.except('user_email').merge(user: user, contact_email: hash['user_email']))
    else

      if hash.has_key?('status') && hash['[status'] == 'Accepted'
        user = FactoryGirl.create(:user_with_membership_app, app_attributes)
        #    company = Company.find_by(company_number: hash[:company_number])
        #    unless company
        #      company = FactoryGirl.create(:company, company_number: hash[:company_number])
        #    end
      else
        app_attributes = hash.except('user_email').merge(email: hash['user_email'])
        user = FactoryGirl.create(:user_with_membership_app, app_attributes.merge(status: 'Accepted'))
      end
    end

  end
end

And(/^I navigate to the edit page for "([^"]*)"$/) do |first_name|
  membership_application = MembershipApplication.find_by(first_name: first_name)
  visit edit_membership_application_path(membership_application)
end

Given(/^I am on "([^"]*)" application page$/) do |first_name|
  membership = MembershipApplication.find_by(first_name: first_name)
  visit membership_application_path(membership)
end

Given(/^I am on the list applications page$/) do
  visit membership_applications_path
end
