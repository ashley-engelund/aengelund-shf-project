FactoryGirl.define do
  factory :address do

    street_address 'Hundvägen 101'
    post_code '310 40'
    kommun 'Halmstad'
    city 'Harplinge'
    country 'Sverige'

    association :region, strategy: :build
  end
end
