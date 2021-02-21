require 'rails_helper'

RSpec.describe Membership, type: :model do
  let(:user1) { create(:user, first_name: 'User1') }
  let(:user2) { create(:user, first_name: 'User2') }

  let(:aug30_2020) { Date.new(2020, 8, 30) }
  let(:sept1_2020) { Date.new(2020, 9, 1) }
  let(:sept2_2020) { Date.new(2020, 9, 2) }
  let(:aug30_2021) { Date.new(2021, 8, 30) }
  let(:sept1_2021) { Date.new(2021, 9, 1) }
  let(:sept2_2021) { Date.new(2021, 9, 1) }
  let(:aug30_2022) { Date.new(2022, 8, 30) }
  let(:sept1_2022) { Date.new(2022, 9, 1) }
  let(:sept2_2022) { Date.new(2022, 9, 1) }
  let(:aug30_2023) { Date.new(2023, 8, 30) }
  let(:sept1_2023) { Date.new(2023, 9, 1) }
  let(:aug30_2024) { Date.new(2024, 8, 30) }

  let(:u1membership_202109) { create(:membership, user: user1,
                                     member_number: 'u1membership_202109',
                                     first_day: sept1_2021,
                                     last_day: aug30_2022) }
  let(:u1membership_202209) { create(:membership, user: user1,
                                     member_number: 'u1membership_202209',
                                     first_day: sept1_2022,
                                     last_day: aug30_2023) }
  let(:u2membership_202009) { create(:membership, user: user2,
                                     member_number: 'u2membership_202009',
                                     first_day: sept1_2020,
                                     last_day: aug30_2021) }
  let(:u2membership_202109) { create(:membership, user: user2,
                                     member_number: 'u2membership_202109',
                                     first_day: sept1_2021,
                                     last_day: aug30_2022) }


  def make_all_memberships
    [u1membership_202109, u1membership_202209,
     u2membership_202009, u2membership_202109]
  end


  describe '.covering_date' do
    it 'where first_day <= the given date and last_day >= the given date' do
      make_all_memberships
      expect(described_class.covering_date(sept1_2021).to_a).to match_array([u1membership_202109,
                                                                             u2membership_202109])
    end

    it 'default date is Date.current' do
      make_all_memberships
      travel_to(sept2_2021) do
        expect(described_class.covering_date.to_a).to match_array([u1membership_202109,
                                                                   u2membership_202109])
      end
    end

    it 'sorted by :last_day, oldest is first' do
      make_all_memberships
      u1membership_202109_2yrs_long = create(:membership, user: user1,
                                         member_number: 'u1membership_202109_2yrs_long',
                                         first_day: sept1_2021,
                                         last_day: aug30_2023)
      u1membership_202209_2yrs_long = create(:membership, user: user1,
                                         member_number: 'u1membership_202209_2yrs_long',
                                         first_day: sept1_2022,
                                         last_day: aug30_2024)
      travel_to(sept2_2022) do
        expect(described_class.covering_date.to_a).to eq([u1membership_202209,
                                                          u1membership_202109_2yrs_long,
                                                          u1membership_202209_2yrs_long])
      end
    end
  end


  describe '.for_user_covering_date' do
    it 'where user is the given user' do
      make_all_memberships
      expect(described_class.for_user_covering_date(user2, sept1_2021).to_a).to match_array([u2membership_202109])
    end

    it 'calls .covering_date with the given date' do
      expect(described_class).to receive(:covering_date).with(sept2_2021)
      described_class.for_user_covering_date(user1, sept2_2021)
    end
  end


  describe '.term_length' do
    it 'gets the value from AppConfiguration' do
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:membership_term_length)
                                                              .and_return(90)
      expect(described_class.term_length).to eq 90.days
    end
  end


  describe 'set_first_day_and_last' do

    it 'default first day is Date.current' do
      expect(subject.first_day).to be_nil
      subject.set_first_day_and_last
      expect(subject.first_day).to eq(Date.current)
    end

    context 'last day is not given' do
      it 'calculates the last day based on the first day given' do
        allow(described_class).to receive(:term_length).and_return(5.days)
        expect(subject.last_day).to be_nil
        first_day = Date.current + 1
        subject.set_first_day_and_last(first_day: first_day)
        expect(subject.last_day).to eq(first_day - 1 + 5.days)
      end
    end

    it 'updates (persists) the first_day and last_day' do
      expect(subject.first_day).to be_nil
      expect(subject.last_day).to be_nil
      first_day = Date.current + 1
      last_day = Date.current + 100
      subject.set_first_day_and_last(first_day:first_day, last_day: last_day)
      expect(subject.first_day).to eq(first_day)
      expect(subject.last_day).to eq(last_day)
    end
  end
end
