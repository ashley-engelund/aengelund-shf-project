FactoryGirl.define do
  sequence(:email) { |num| "email_#{num}@random.com" }

  factory :user do
    email
    password 'my_password'
    admin false
    is_member false


    factory :user_with_membership_app do
      after(:create) do |user, evaluator|
        create_list(:membership_application, 1, user: user, company_number: 5712213304)
      end
    end

    factory :member_with_membership_app do
      is_member true
      after(:create) do |user, evaluator|
        evaluator.is_member = true
        create_list(:membership_application, 1, user: user, company_number: 5562728336, status: 'Godkänd')

      end
    end
  end

end
