# Steps for viewing membership status, changing it

Then(/I should be a member/) do
  @user.reload  # ensure the info is up to date
  expect(@user.member).to be_truthy
end

Then(/I should not be a member/) do
  @user.reload
  expect(@user.member).not_to be_truthy
end

And("My membership expiration date is {date}") do |date|
  expect(@user.membership_expire_date).to eq date
end
