require 'rails_helper'

RSpec.describe MembershipsManager, type: :model do
  let(:user) { build(:user) }
  let(:mock_membership) { double(Membership) }
  let(:mock_memberships) { double(ActiveRecord::Relation) }

  before(:each) do
    allow(user).to receive(:memberships).and_return(mock_memberships)
  end

  describe '.most_recent_membership_method' do
    it 'is :last_day ' do
      expect(described_class.most_recent_membership_method).to eq :last_day
    end
  end

  describe '.days_can_renew_early' do
    it 'gets the value from AppConfiguration and returns the number of days (Duration)' do
      expect( AdminOnly::AppConfiguration.config_to_use).to receive(:payment_too_soon_days)
                                                              .and_return(7)
      expect(described_class.days_can_renew_early).to eq 7.days
    end
  end


  describe '.grace_period' do
    it 'gets the value from AppConfiguration and returns the number of days (Duration)' do
      expect( AdminOnly::AppConfiguration.config_to_use).to receive(:membership_expired_grace_period)
                                                              .and_return(90)
      expect(described_class.grace_period).to eq 90.days
    end
  end


  describe '.get_next_membership_number' do
    pending
  end


  describe 'most_recent_membership' do
    let(:membership_ending_2021_12_31) {  build(:membership, last_day: Date.new(2021, 12, 31)) }

    before(:each) do
      allow(mock_memberships).to receive(:empty?).and_return(false)
      allow(mock_memberships).to receive(:order).and_return(mock_memberships)
      allow(mock_memberships).to receive(:last).and_return(membership_ending_2021_12_31)
    end

    it "gets the user's memberships" do
      expect(user).to receive(:memberships).and_return(mock_memberships)
      subject.most_recent_membership(user)
    end

    it 'returns nil if there are no memberships for the user' do
      allow(mock_memberships).to receive(:empty?).and_return(true)
      expect(subject.most_recent_membership(user)).to be_nil
    end

    it 'sorts them with the most_recent_membership method' do
      allow(subject).to receive(:most_recent_membership_method)
                          .and_return(:some_method)
      expect(mock_memberships).to receive(:order).with(:some_method)
      subject.most_recent_membership(user)
    end

    it 'returns the last one' do
      expect(mock_memberships).to receive(:last).and_return(membership_ending_2021_12_31)
      expect(subject.most_recent_membership(user)).to eq membership_ending_2021_12_31
    end
  end


  describe 'most_recent_membership_method' do
    it 'calls the class method' do
      expect(described_class).to receive(:most_recent_membership_method)
      subject.most_recent_membership_method
    end
  end


  describe 'most_recent_membership_last_day' do
    it 'is the last day for the most recent membership' do
      expect(mock_membership).to receive(:last_day).and_return(Date.current + 2)
      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.most_recent_membership_last_day(user)).to eq(Date.current + 2)
    end

    it 'nil if the user has no memberships' do
      allow(subject).to receive(:most_recent_membership).and_return(nil)
      expect(subject.most_recent_membership_last_day(user)).to be_nil
    end
  end


  describe 'has_membership_on?' do

    it 'false if the given date is nil' do
      expect(subject.has_membership_on?(user, nil)).to be_falsey
    end

    context 'given date is not nil' do

      it 'calls Membership.exists_for_user_on to get any memberships that covered that date' do
        allow(mock_memberships).to receive(:exists?)
        expect(Membership).to receive(:exists_for_user_on).and_return(mock_memberships)
        subject.has_membership_on?(user, Date.current)
      end

      it 'returns the value of .exists? for the records that Membership.exists_for_user_on returns' do
        allow(Membership).to receive(:exists_for_user_on).and_return(mock_memberships)

        expect(mock_memberships).to receive(:exists?).and_return(true)
        subject.has_membership_on?(user, Date.current)
      end
    end
  end


  describe 'membership_in_grace_period?' do

    it 'false if user has no memberships' do
      expect(subject).to receive(:most_recent_membership).and_return(nil)
      expect(subject.membership_in_grace_period?(user)).to be_falsey
    end

    it 'default given date is Date.current' do
      allow(subject).to receive(:grace_period).and_return(0.days)
      allow(mock_membership).to receive(:last_day).and_return(Date.current)

      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.membership_in_grace_period?(user)).to be_truthy
    end

    it 'default is to use the most recent membership' do
      allow(subject).to receive(:grace_period).and_return(2.days)
      allow(mock_membership).to receive(:last_day).and_return(Date.current)

      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)
      expect(subject.membership_in_grace_period?(user)).to be_truthy
    end

    it 'returns date_in_grace_period?(given date, last day of most recent membership)' do
      given_date = Date.current + 1
      membership_last_day = Date.current

      allow(subject).to receive(:grace_period).and_return(2.days)
      allow(mock_membership).to receive(:last_day).and_return(membership_last_day)
      expect(subject).to receive(:most_recent_membership).and_return(mock_membership)

      expect(subject).to receive(:date_in_grace_period?)
                           .with(given_date, last_day: membership_last_day)
      subject.membership_in_grace_period?(user, given_date)
    end
  end


  describe 'date_in_grace_period?' do
    let(:grace_period) { 2.days }
    before(:each) do
      allow(subject).to receive(:grace_period).and_return(grace_period)
    end

    it 'default date is Date.current' do
      expect(subject.date_in_grace_period?(last_day: Date.current - 1,
                                           grace_days: 2)).to be_truthy
      expect(subject.date_in_grace_period?(last_day: Date.current - 1,
                                           grace_days: 1)).to be_truthy
      expect(subject.date_in_grace_period?(last_day: Date.current - 2,
                                           grace_days: 1)).to be_falsey
    end

    it 'default last day is Date.current' do
      expect(subject.date_in_grace_period?(Date.current + 1.day,
                                           grace_days: 0)).to be_falsey
      expect(subject.date_in_grace_period?(Date.current + 1,
                                           grace_days: 1)).to be_truthy
    end

    it 'default grace days is grace_period' do
      expect(subject).to receive(:grace_period).and_return(3.days)
      expect(subject.date_in_grace_period?(Date.current + 3.days,
                                           last_day: Date.current)).to be_truthy
    end


    it 'false if given_date is before the first day' do
      expect(subject.date_in_grace_period?(Date.current,
                                           last_day: Date.current - 1,
                                           grace_days: 0)).to be_falsey
    end

    context 'given date is on or after the first day of the time period' do

      it 'false if the given date is before the last day' do
        expect(subject.date_in_grace_period?(Date.current - 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end

      it 'false if the given date is the last day' do
        expect(subject.date_in_grace_period?(Date.current,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end

      it 'true if the given date is before (last day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period - 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_truthy
      end

      it 'true if this date is the last day of the grace period (== first day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_truthy
      end

      it 'false if the given date is after (last day + grace period)' do
        expect(subject.date_in_grace_period?(Date.current + grace_period + 1.day,
                                             last_day: Date.current,
                                             grace_days: grace_period)).to be_falsey
      end
    end
  end


  describe 'days_can_renew_early' do
    it 'calls the class method' do
      expect(described_class).to receive(:days_can_renew_early)
      subject.days_can_renew_early
    end
  end


  describe 'grace_period' do
    it 'calls the class method' do
      expect(described_class).to receive(:grace_period)
      subject.grace_period
    end
  end


  describe 'can_renew_today?' do
    it 'calls can_renew_on? for Date.current' do
      expect(subject).to receive(:can_renew_on?).with(user, Date.current)
      subject.can_renew_today?(user)
    end
  end

  describe 'can_renew_on?' do

    it 'false if the user has no memberships' do
      allow(subject).to receive(:has_membership_on?).with(user, anything)
                                                    .and_return(false)
      expect(subject.can_renew_on?(user, Date.current)).to be_falsey
    end

    context 'user has memberships' do
      let(:membership_last_day) { Date.current }
      let(:num_days_can_renew_early) { 3 }

      before(:each) do
        allow(subject).to receive(:has_membership_on?).and_return(true)
        allow(subject).to receive(:days_can_renew_early).and_return(num_days_can_renew_early)
        allow(subject).to receive(:most_recent_membership_last_day).and_return(membership_last_day)
      end

      it 'default date is Date.current' do
        expect(subject.can_renew_on?(user)).to be_truthy
      end

      context 'given date is on or before the last day of the current membership' do

        it 'true if given date is the last day' do
          expect(subject.can_renew_on?(user, membership_last_day)).to be_truthy
        end

        it 'true if given date == (last day - days it is too early to renew)' do
          expect(subject.can_renew_on?(user, membership_last_day - num_days_can_renew_early)).to be_truthy
        end

        it 'true if given date after (last day - days it is too early to renew)' do
          expect(subject.can_renew_on?(user, membership_last_day - num_days_can_renew_early + 1)).to be_truthy
        end

        it 'false if the date is before (expiry - days it is too early to renew)' do
          expect(subject.can_renew_on?(user, membership_last_day - num_days_can_renew_early - 1)).to be_falsey
        end
      end

      context 'given date is after the last day of the current membership' do

        it 'is result of whether the membership is in the grace period' do
          given_date = Date.current + 1
          expect(subject).to receive(:membership_in_grace_period?)
                               .with(user, given_date)
          subject.can_renew_on?(user, given_date)
        end
      end
    end
  end
end
