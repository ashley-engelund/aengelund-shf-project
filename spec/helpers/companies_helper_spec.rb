require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do

  describe '#company_complete?' do
    it 'returns false if company is nil' do
      company = nil
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns false if company name is nil' do
      company = FactoryGirl.create(:company, name: nil)
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns false if company region is nil' do
      company = FactoryGirl.create(:company, region: nil)
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns false is company name or region is empty string' do
      company = FactoryGirl.create(:company, name: '')
      expect(helper.company_complete?(company)).to eq false
    end

    it 'returns true if company name and region are non-empty string' do
      company = FactoryGirl.create(:company)
      expect(helper.company_complete?(company)).to eq true
    end

  end

  describe 'companies' do

    it '#last_category_name' do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
      company = FactoryGirl.create(:company, company_number: 5562252998)

      employee1 = create(:user, email: 'emp1@happymutts.com')
      employee2 = create(:user, email: 'emp2@happymutts.com')
      employee3 = create(:user, email: 'emp3@happymutts.com')

      create(:membership_application, user: employee1, status: 'Godkänd', num_categories: 1, category_name: 'cat1', company_number: '5562252998')
      create(:membership_application, user: employee2, status: 'Godkänd', num_categories: 1, category_name: 'cat2', company_number: '5562252998')
      create(:membership_application, user: employee3, status: 'Godkänd', num_categories: 1, category_name: 'cat3', company_number: '5562252998')

      expect(helper.last_category_name(company)).to eq 'cat3'

    end

    it '#list_categories' do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
      company = FactoryGirl.create(:company, company_number: 5562252998)

      employee1 = create(:user, email: 'emp1@happymutts.com')
      employee2 = create(:user, email: 'emp2@happymutts.com')
      employee3 = create(:user, email: 'emp3@happymutts.com')

      create(:membership_application, user: employee1, status: 'Godkänd', num_categories: 1, category_name: 'cat1', company_number: '5562252998')
      create(:membership_application, user: employee2, status: 'Godkänd', num_categories: 1, category_name: 'cat2', company_number: '5562252998')
      create(:membership_application, user: employee3, status: 'Godkänd', num_categories: 1, category_name: 'cat3', company_number: '5562252998')

      expect(helper.list_categories(company)).to eq 'cat1 cat2 cat3'
      expect(helper.list_categories(company)).not_to include 'Träning'
    end
  end
end
