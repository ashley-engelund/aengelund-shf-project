FactoryGirl.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    email
    password 'my_password'
    admin false
    is_member false

    transient do
      company_number 5712213304
      company nil
      first_name 'FirstName'
      last_name 'LastName'
      category_name 'Category1'
      status 'pending'
    end

    factory :user_with_membership_app do
      after(:create) do |user, evaluator|
        create_list(:membership_application, 1, user: user, first_name: evaluator.first_name, category_name: evaluator.category_name, company_number: evaluator.company_number, contact_email: user.email)
        user.save
      end
    end

    factory :member_with_membership_app do
      after(:create) do |user, evaluator|
        user.is_member = true
        create_list(:membership_application, 1, user: user, status: 'Accepted', first_name: evaluator.first_name, category_name: evaluator.category_name, company_number: evaluator.company_number, contact_email: user.email)
        user.save
      end
    end

  end

end
