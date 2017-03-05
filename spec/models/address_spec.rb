require 'rails_helper'

RSpec.describe Address, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company_address)).to be_valid
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
    it { is_expected.to have_db_column :addressable_id }
    it { is_expected.to have_db_column :addressable_type }
    it { is_expected.to have_db_column :latitude }
    it { is_expected.to have_db_column :longitude }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :addressable }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:region) }
    it { is_expected.to belong_to(:addressable) }
  end


  describe 'scopes' do

    let(:co_has_regions) { create(:company, name: 'Has Region', company_number: '4268582063', city: 'HasRegionBorg') }
    let(:co_missing_region) { create(:company, name: 'Missing Region', company_number: '6112107039', city: 'NoRegionBorg') }

    let(:addr_has_region) { co_has_regions.addresses.first }

    let(:no_region) { addr_no_region = co_missing_region.addresses.first
    addr_no_region.update(region: nil)
    addr_no_region
    }

    let!(:has_regions) { [addr_has_region] }
    let!(:lacking_regions) { [no_region] }


    describe 'has_region' do

      it 'only returns addresses that have a region' do
        has_region_scope = Address.has_region

        expect(has_region_scope).to match_array(has_regions), "expected #{has_regions.pretty_inspect} },\n\n but got #{has_region_scope.pretty_inspect} }"
      end

      it 'does not return any addresses that do not have a region' do
        has_region_scope = Address.has_region
        expect(has_region_scope & lacking_regions).to match_array([])
      end

    end


    describe 'lacking_region' do

      it 'only returns addresses that do not have a region' do
        lacking_region_scope = Address.lacking_region
        expect(lacking_region_scope).to match_array(lacking_regions)
      end

      it 'does not return any addresses that do have a region' do
        lacking_region_scope = Address.lacking_region
        expect(lacking_region_scope & has_regions).to match_array([])
      end

    end

  end


  describe 'gecoding' do

    let(:expected_streetaddress) { 'Kvarnliden 10' }
    let(:expected_postcode) { '310 40' }
    let(:expected_kommun) { 'Halmstad V' }
    let(:expected_city) { 'Harplinge' }
    let(:expected_country) { 'Sveriges' }

    # orig lat and long, which is wrong and should be updated if the address changes
    let(:orig_lat) { 56.7439545 }
    let(:orig_long) { 12.7276875 }


    it 'geocode from address' do
      addr = Address.new(street_address: expected_streetaddress,
                         city: expected_city,
                         post_code: expected_postcode,
                         country: 'Sweden')

      addr.validate

      expect(addr.latitude).to eq(56.7440333)
      expect(addr.longitude).to eq(12.727637)
    end


    describe 'changed address so update latitude, longitude' do

      let(:addr) { Address.new(street_address: expected_streetaddress,
                               city: expected_city,
                               post_code: expected_postcode,
                               kommun: expected_kommun,
                               country: expected_country)
      }

      it 'changed street address' do
        addr.street_address = 'Kvarnliden 2'
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude).to eq(56.7442343)
        expect(addr.longitude).to eq(12.7255982)
      end

      it 'changed kommun' do
        addr.kommun = 'Halmstad Ö'
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude).to eq(56.7440333)
        expect(addr.longitude).to eq(12.727637)
      end

      it 'changed city' do
        addr.city = 'Plingshult'
        addr.street_address = ''
        addr.post_code = ''

        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude).to eq(56.633333)
        expect(addr.longitude).to eq(13.2)
      end

      it 'changed region' do
        new_region = create(:region, name: 'New Region', code: 'NR')
        addr.region = new_region
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude).to eq(56.7440333)
        expect(addr.longitude).to eq(12.727637)
      end

      it 'changed country' do
        addr.country = 'Norway'
        addr.validate

        expect(addr.latitude).not_to eq(orig_lat)
        expect(addr.longitude).not_to eq(orig_long)

        expect(addr.latitude).to eq(56.7440333)
        expect(addr.longitude).to eq(12.727637)
      end


    end


    it 'bad address that does not return latitude and/or longitude' do

      addr = Address.new(street_address: expected_streetaddress,
                         city: 'Budapest',
                         post_code: expected_postcode,
                         country: 'Sweden')

      addr.validate

      expect(addr.latitude).to eq(nil)
      expect(addr.longitude).to eq(nil)
    end


  end
end
