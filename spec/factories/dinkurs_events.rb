FactoryGirl.define do

  sequence(:dinkurs_id) { |num| "dke-#{num}" }

  factory :dinkurs_event do

    event_name  "Event #{dinkurs_id}"

  end
end
