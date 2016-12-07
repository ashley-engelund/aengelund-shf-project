FactoryGirl.define do

  sequence(:cat_name_seq, "Business Category", 1) { |name, num| "#{name} #{num}" }

  factory :membership_application do
    first_name 'Firstname'
    last_name 'Lastname'
    company_number '5562252998'
    phone_number 'MyString'
    contact_email 'MyString@email.com'
    status 'pending'

    association :user

    transient do
      num_categories 1
      category_name "Business Category"
    end

    after(:create) do |membership_app, evaluator|
      membership_app.user.membership_applications << membership_app  if membership_app.user

      if evaluator.num_categories == 1
        membership_app.business_categories << create(:business_category, name: evaluator.category_name)
      else
        evaluator.num_categories.times do |cat_num|
          membership_app.business_categories << create(:business_category, name: "#{evaluator.category_name} #{cat_num + 1}")
        end
      end

      if evaluator.status == 'Accepted'
        unless (co = Company.find_by_company_number(evaluator.company_number))
          co = create(:company, company_number: evaluator.company_number)
        end
        membership_app.company = co
      end

    end

  end
end
