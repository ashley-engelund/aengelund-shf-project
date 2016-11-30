require 'rails_helper'

RSpec.describe MembershipApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :status }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_and_belong_to_many :business_categories }
    it { is_expected.to belong_to :company }
  end

  describe 'test factories' do

    it 'default: 1 category with default category name' do
      member_app = create(:membership_application)
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name).to eq("Business Category"), "The first category name should have been 'Business Category' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '2 categories with sequence names' do
      member_app = create(:membership_application, num_categories: 2)
      expect(member_app.business_categories.count).to eq(2), "The number of categories should have been 2 but instead was #{member_app.business_categories.count}"
      expect(member_app.business_categories.first.name).to eq("Business Category 1"), "The first category name should have been 'Business Category 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Business Category 2"), "The last category name should have been 'Business Category 2' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '1 category with the name "Special"' do
      member_app = create(:membership_application, category_name: "Special")
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name).to eq("Special"), "The first category name should have been 'Special' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '3 categories with the name "Special 1, Special 2, Special 3"' do
      member_app = create(:membership_application, category_name: "Special", num_categories: 3)
      expect(member_app.business_categories.count).to eq(3)
      expect(member_app.business_categories.first.name).to eq("Special 1"), "The first category name should have been 'Special 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Special 3"), "The first category name should have been 'Special 3' but instead was '#{member_app.business_categories.last.name}'"
    end


  end

end
