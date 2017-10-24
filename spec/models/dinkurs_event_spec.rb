require 'rails_helper'

require 'pp'

require_relative(File.join(__dir__, '..', '..', 'app', 'services', 'dinkurs_service'))



RSpec.describe DinkursEvent, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:dinkurs_event)).to be_valid
    end

    it 'creates a new dinkurs event for a company' do
      company = create(:company)
      new_dk_event1 = create(:dinkurs_event, company: company)
      expect(new_dk_event1.company.company_number).to eq(company.company_number)
    end

    it 'creates a new dinkurs event id from a sequence' do
      company = create(:company)
      new_dk_event1 = create(:dinkurs_event, company: company)
      new_dk_event2 = create(:dinkurs_event, company: company)
      expect(new_dk_event1.dinkurs_id).not_to eq(new_dk_event2.dinkurs_id)
    end

  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :dinkurs_id }

    it { is_expected.to have_db_column :event_name }
    it { is_expected.to have_db_column :event_place_geometry_location }
    it { is_expected.to have_db_column :event_host }

    it { is_expected.to have_db_column :event_fee }
    it { is_expected.to have_db_column :event_fee_tax }

    it { is_expected.to have_db_column :event_pub }  # date
    it { is_expected.to have_db_column :event_apply } # date
    it { is_expected.to have_db_column :event_start } # date
    it { is_expected.to have_db_column :event_stop } # date

    it { is_expected.to have_db_column :event_participant_number }
    it { is_expected.to have_db_column :event_participant_reserve }

    it { is_expected.to have_db_column :event_participants }

    it { is_expected.to have_db_column :event_occasions }
    it { is_expected.to have_db_column :event_group }

    it { is_expected.to have_db_column :event_position }  # number
    it { is_expected.to have_db_column :event_instructor_1 }
    it { is_expected.to have_db_column :event_instructor_2 }
    it { is_expected.to have_db_column :event_instructor_3 }


    it { is_expected.to have_db_column :event_infotext }
    it { is_expected.to have_db_column :event_commenttext }


    it { is_expected.to have_db_column :event_ticket_info }

    it { is_expected.to have_db_column :event_key }  # unique identifier for DinKurs used to construct the event_url_key ?
    it { is_expected.to have_db_column :event_url_id }
    it { is_expected.to have_db_column :event_url_key }

    it { is_expected.to have_db_column :event_completion_text }
    it { is_expected.to have_db_column :event_aftertext }

    it { is_expected.to have_db_column :event_event_dates }

  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :dinkurs_id }
    it { is_expected.to validate_presence_of :event_name }
    it { is_expected.to validate_presence_of :event_start }
    it { is_expected.to validate_presence_of :event_key }
    it { is_expected.to validate_presence_of :event_url_id }
    it { is_expected.to validate_presence_of :event_url_key }
  end


  describe 'Associations' do
    it { is_expected.to belong_to(:company) }  # TODO member or company or either?
  end


end
