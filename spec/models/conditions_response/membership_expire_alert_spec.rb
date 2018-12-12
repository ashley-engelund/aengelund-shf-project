require 'rails_helper'


RSpec.describe MembershipExpireAlert, type: :model do

  let(:jan_1) { Time.zone.local(2018, 1, 1) }

  let(:nov_29) { Time.zone.local(2018, 11, 29) }
  let(:nov_30) { Time.zone.local(2018, 11, 30) }
  let(:dec_1) { Time.zone.local(2018, 12, 1) }
  let(:dec_2) { Time.zone.local(2018, 12, 2) }
  let(:dec_3) { Time.zone.local(2018, 12, 3) }

  let(:nov_29_last_year) { Time.zone.local(2017, 11, 29) }
  let(:nov_30_last_year) { Time.zone.local(2017, 11, 30) }
  let(:dec_1_last_year) { Time.zone.local(2017, 12, 1) }
  let(:dec_2_last_year) { Time.zone.local(2017, 12, 2) }
  let(:dec_3_last_year) { Time.zone.local(2017, 12, 3) }

  let(:nov_30_next_year) { Time.zone.local(2019, 11, 30) }


  let(:success) { Payment.order_to_payment_status('successful') }


  let(:config) { { days: [1, 7, 14, 30] } }

  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end

  describe '.send_alert_this_day?(config, user)' do


    context 'user is a member' do

      context 'membership has not expired yet' do

        let(:paid_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }


        it 'true when the day  is in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, paid_member, dec_1)).to be_truthy
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, paid_member, dec_2)).to be_falsey
        end

      end # context 'membership has not expired yet'


      context 'membership expiration is before or on the given date to check' do

        let(:paid_expires_today_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  dec_2_last_year,
                 expire_date: User.expire_date_for_start_date(dec_2_last_year))
          member
        }


        context 'membership expires the day after the given date (nov 29), expires dec 1' do

          it 'true if the day is in the config list of days to send the alert (= 1)' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.send_alert_this_day?({ days: [1] }, paid_expires_today_member, nov_30)).to be_truthy
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(described_class.send_alert_this_day?(config, paid_expires_today_member, nov_29)).to be_falsey
          end

        end

        context 'membership expires on the given date (dec 1), expired dec 1' do

          it 'false even if the day is in the list of days to send it' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.send_alert_this_day?({ days: [0] }, paid_expires_today_member, dec_1)).to be_falsey
          end

        end

      end # context 'membership expiration is before or on the given date'


      context 'membership has expired' do

        let(:paid_expired_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  nov_30_last_year,
                 expire_date: User.expire_date_for_start_date(nov_30_last_year))
          member
        }


        it 'false if the day is in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, paid_expired_member, dec_1)).to be_falsey
        end

        it 'false if the day is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, paid_expired_member, dec_2)).to be_falsey
        end

      end

    end


    context 'user is not a member and has no payments: always false' do

      let(:user) { create(:user) }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(config, user, dec_2)).to be_falsey
      end

      it 'false when the day is not in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(config, user, dec_3)).to be_falsey
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.mailer_method).to eq :membership_expiration_reminder
  end

end
