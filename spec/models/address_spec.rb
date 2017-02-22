require 'rails_helper'

RSpec.describe Address, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:address)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :street_address }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :kommun }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :region_id }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :country }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:region) }
  end


end
