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
    end

    factory :user_with_membership_app do
      after(:create) do |user, evaluator|
        create_list(:membership_application, 1, user: user, company_number: evaluator.company_number)
      end
    end

    factory :member_with_membership_app do
      after(:create) do |user, evaluator|
        user.is_member = true
        create_list(:membership_app_approved, 1, user: user, company: evaluator.company)
        user.save!
      end
    end

  end

end
