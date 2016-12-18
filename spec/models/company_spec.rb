require 'rails_helper'

RSpec.describe Company, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :street }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :region }
    it { is_expected.to have_db_column :website }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

  end

  describe 'Associations' do
    it { is_expected.to have_many(:business_categories).through(:membership_applications) }
    it { is_expected.to have_many(:membership_applications) }
  end


  describe 'categories = all employee categories' do

    before(:all) do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all

      company = create(:company, company_number: '5562252998')

      employee1 = create(:user, email: 'emp1@happymutts.com')
      employee2 = create(:user, email: 'emp2@happymutts.com')
      employee3 = create(:user, email: 'emp3@happymutts.com')

    end

    it '3 employees, each with 1 unique category' do
      create(:membership_application, user: User.find_by_email('emp1@happymutts.com'), status: 'Godkänd', num_categories: 1, category_name: 'cat1', company_number: '5562252998')
      create(:membership_application, user: User.find_by_email('emp2@happymutts.com'), status: 'Godkänd', num_categories: 1, category_name: 'cat2', company_number: '5562252998')
      create(:membership_application, user: User.find_by_email('emp3@happymutts.com'), status: 'Godkänd', num_categories: 1, category_name: 'cat3', company_number: '5562252998')

      expect(Company.find_by_company_number('5562252998').business_categories.count).to eq 3
      expect(Company.find_by_company_number('5562252998').business_categories.map { |c| c[:name] }).to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it '3 employees, each with the same category' do

      category = create(:business_category, name: 'cat1')

      m1 =create(:membership_application, user: User.find_by_email('emp1@happymutts.com'), num_categories: 0, status: 'Godkänd', company_number: '5562252998')
      m1.business_categories << category

      m2 = create(:membership_application, user: User.find_by_email('emp2@happymutts.com'), num_categories: 0, status: 'Godkänd', company_number: '5562252998')
      m2.business_categories << category

      m3 = create(:membership_application, user: User.find_by_email('emp3@happymutts.com'), num_categories: 0, status: 'Godkänd', company_number: '5562252998')
      m3.business_categories << category

      expect(Company.find_by_company_number('5562252998').business_categories.distinct.count).to eq 1
      expect(Company.find_by_company_number('5562252998').business_categories.distinct.map { |c| c[:name] }).to contain_exactly('cat1')
    end

  end
end
