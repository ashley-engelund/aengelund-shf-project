FactoryGirl.define do

  sequence(:dinkurs_id) { |num| "dke-#{num}" }

  factory :dinkurs_event do

    event_name "Event #{dinkurs_id}"
    event_start DateTime.parse("1 April 2017")
    event_key "VoofVoofVoofVoof12345"

    association :company, factory: :company

    after(:build) do | dk_event, evaluator |
      dk_event.event_url_id = ( evaluator.event_url_id ? evaluator.event_url_id : "https://dinkurs.se/appliance/?event_id=#{dk_event.dinkurs_id}" )
      dk_event.event_url_key = ( evaluator.event_url_key ? evaluator.event_url_key : "https://dinkurs.se/appliance/?event_key=#{dk_event.event_key}" )
    end

  end

end
