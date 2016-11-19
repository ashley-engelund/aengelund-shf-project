FactoryGirl.define do
  factory :uploaded_file do
    title "some title"
    description "some description"

    trait :png do
      actual_file { File.new("#{Rails.root}/spec/support/fixtures/image.png") }
    end
    trait :gif do
      actual_file { File.new("#{Rails.root}/spec/support/fixtures/image.gif") }
    end
    trait :jpg do
      actual_file { File.new("#{Rails.root}/spec/support/fixtures/image.jpg") }
    end

    factory :png_attachment,    traits: [:png]
    factory :jpg_attachment,    traits: [:jpg]
    factory :gif_attachment,    traits: [:gif]
  end

end
