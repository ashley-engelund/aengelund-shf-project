require 'rails_helper'

RSpec.describe RequirementsForMembership, type: :model do

  let(:subject) { RequirementsForMembership }

  let(:user) { create(:user) }

  let(:member) { create(:member_with_membership_app) }


  describe '#satisfied?' do

    context 'does not meet membership requirements' do

      it 'user does not have an approved application (does have a payment and membership term has not expired)' do

        start_date, expire_date = User.next_membership_payment_dates(user.id)
        create(:membership_fee_payment,
               :successful,
               user: user,
               start_date: start_date,
               expire_date: expire_date)

        expect(subject.satisfied?(user)).to be_falsey
      end

      it 'membership term has expired (does have an approved application and does have a payment for membership fee)' do

        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: Time.zone.today - 1.year - 1.month,
               expire_date: Time.zone.today - 1.year )

        expect(subject.satisfied?(user)).to be_falsey
      end

      it 'has an approved application but has not paid the membership fee' do
        user_with_approved_app = create(:user_with_membership_app)
        shf_app = user_with_approved_app.shf_applications.last
        shf_app.start_review
        shf_app.accept!
        expect(subject.satisfied?(user_with_approved_app))
      end

    end


    context 'meets the membership requirements' do

      it 'has an approved application AND membership fee paid AND membership term has not expired' do

        start_date, expire_date = User.next_membership_payment_dates(member.id)
        create(:membership_fee_payment,
               :successful,
               user: member,
               start_date: start_date,
               expire_date: expire_date)

        expect(subject.satisfied?(member)).to be_truthy
      end

    end

  end

end
