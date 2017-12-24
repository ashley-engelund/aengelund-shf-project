FactoryGirl.define do

  factory :payment do
    user
    company nil
    payment_type Payment::PAYMENT_TYPE_MEMBER
    status Payment::CREATED
    start_date Time.zone.today
    expire_date Time.zone.today + 1.year - 1.day
    hips_id 'none'

    trait :successful do
      status Payment::SUCCESSFUL
    end

    trait :created do
      status Payment::CREATED
    end

    trait :pending do
      status Payment::PENDING
    end

    trait :expired do
      status Payment::EXPIRED
    end

    trait :awaiting_payments do
      status Payment::AWAITING_PAYMENTS
    end


    factory :membership_fee_payment do #, class: MembershipFeePayment do
      payment_type Payment::PAYMENT_TYPE_MEMBER
    end

    factory :branding_fee_payment do #, class: BrandingFeePayment do
      payment_type Payment::PAYMENT_TYPE_BRANDING
    end

  end
end
