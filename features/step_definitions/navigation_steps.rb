Given(/^I am on the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'landing'
      path = root_path
    when 'login'
      path = new_user_session_path
    when 'edit my application'
      path = edit_membership_application_path(@user.membership_applications.last)
    when 'business categories'
      path = business_categories_path
    when 'all companies'
      path = companies_path
    when 'create a new company'
      path = new_company_path
    when 'edit my company'
      if @user
        path = edit_company_path(@user.membership_applications.last.company) if @user.membership_applications.last && @user.membership_applications.last.company
      end
    else
      path = 'no path set'
  end
  visit path
end

When(/^I fail to visit the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'applications index'
      path = membership_applications_path
    else
      path = 'path not set'
  end
  visit path
  expect(current_path).not_to be path
end
