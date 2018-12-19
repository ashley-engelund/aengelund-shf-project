require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe MembershipExpireAlert, type: :model do


  let(:jan_1) { Date.new(2018, 1, 1) }

  let(:nov_29) { Date.new(2018, 11, 29) }
  let(:nov_30) { Date.new(2018, 11, 30) }
  let(:dec_1) { Date.new(2018, 12, 1) }
  let(:dec_2) { Date.new(2018, 12, 2) }
  let(:dec_3) { Date.new(2018, 12, 3) }

  let(:nov_29_last_year) { Date.new(2017, 11, 29) }
  let(:nov_30_last_year) { Date.new(2017, 11, 30) }
  let(:dec_1_last_year) { Date.new(2017, 12, 1) }
  let(:dec_2_last_year) { Date.new(2017, 12, 2) }
  let(:dec_3_last_year) { Date.new(2017, 12, 3) }

  let(:nov_30_next_year) { Date.new(2019, 11, 30) }


  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:membership_will_expire_condition) do
    create(:condition, class_name: 'MembershipExpireAlert',
                       name: 'membership_will_expire',
                       timing: 'before',
                       config: { days: [10, 5, 2] })
  end

  let(:payment_date_2018_11_21) { Time.zone.local(2018, 11, 21) }
  let(:success) { Payment.order_to_payment_status('successful') }

  let(:condition) { create(:condition, :before, config: { days: [1, 7, 14, 30]} ) }

  let(:config) { { days: [1, 7, 14, 30] } }

  let(:timing) { MembershipExpireAlert::TIMING_BEFORE }



  let(:member_payment1) do
    start_date, expire_date = User.next_membership_payment_dates(user.id)
    create(:payment, user: user, status: success,
           payment_type: Payment::PAYMENT_TYPE_MEMBER,
           notes: 'these are notes for member payment1',
           start_date: start_date,
           expire_date: expire_date)
  end
  let(:filepath) { File.join(Rails.root, 'tmp', 'testfile') }
  let(:log)      { ActivityLogger.open(filepath, 'TEST', 'open', false) }


  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.condition_response' do

    before(:each) do
      member_payment1.update_attribute(:expire_date, payment_date_2018_11_21)

      File.delete(filepath) if File.file?(filepath)
    end

    after(:all) do
      File.delete(File.join(Rails.root, 'tmp', 'testfile'))
    end

    context 'membership_will_expire' do

      context 'days-before includes today' do

        before(:each) { Rails.configuration.action_mailer.delivery_method = :mailgun
        ApplicationMailer.mailgun_client.enable_test_mode!
        }

        after(:each) { ApplicationMailer.mailgun_client.disable_test_mode! }


        it 'sends alert email to user and logs a message' do

          expect(MemberMailer).to receive(:membership_expiration_reminder).with(user)
            .exactly(membership_will_expire_condition.config[:days].length).times
            .and_call_original

        membership_will_expire_condition.config[:days].each do |days_until|

          Timecop.freeze(payment_date_2018_11_21 - days_until.days)

          MembershipExpireAlert.condition_response(membership_will_expire_condition, log)

            Timecop.return

            email = ActionMailer::Base.deliveries.last
            expect(email).to deliver_to(user.email)

            expect(File.read(filepath)).to include "[info] Expire alert sent to #{user.email}"
          end
        end


        it 'logs an error if any error is raised or mail has errors' do

          expect(MemberMailer).to receive(:membership_expiration_reminder).with(user)
                                      .exactly(membership_will_expire_condition.config[:days].length).times
                                      .and_call_original

          allow_any_instance_of(Mail::Message).to receive(:deliver)
            .and_raise(  Net::ProtocolError )

          membership_will_expire_condition.config[:days].each do |days_until|

            Timecop.freeze(payment_date_2018_11_21 - days_until.days)

            MembershipExpireAlert.condition_response(membership_will_expire_condition, log)

            Timecop.return

            expect(ActionMailer::Base.deliveries.size).to eq 0
            expect(File.read(filepath)).to include "[info] Expire alert mail ATTEMPT FAILED: to #{user.email}"
          end
        end

      end # context 'days-before includes today'


      it 'does not send email if days-before does not include today' do

        expect(MemberMailer).not_to receive(:membership_expiration_reminder)

        days_ago = membership_will_expire_condition.config[:days].max + 1

        Timecop.freeze(payment_date_2018_11_21 - days_ago.days)

        MembershipExpireAlert.condition_response(membership_will_expire_condition, log)

        Timecop.return

        expect(File.read(filepath)).not_to include "[info] Expire alert sent to #{user.email}"
      end
    end
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


        it 'true when the day is in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, config, paid_member)).to be_truthy
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_member)).to be_falsey
        end

      end # context 'membership has not expired yet'


      context 'membership expiration is before or on the given date to check' do

        context 'membership expires 1 day after today (dec 1); expires dec 2' do

          let(:paid_expires_tomorrow_member) {
            member = create(:member_with_membership_app)

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_3_last_year,
                   expire_date: User.expire_date_for_start_date(dec_3_last_year))
            member
          }

          it 'true if the day is in the config list of days to send the alert (= 1)' do
            expect(paid_expires_tomorrow_member.membership_expire_date).to eq dec_2
            expect(described_class.send_alert_this_day?(timing, { days: [1] }, paid_expires_tomorrow_member)).to be_truthy
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_expires_tomorrow_member)).to be_falsey
          end

        end

        context 'membership expires on the given date (dec 1), expired dec 1' do

          let(:paid_expires_today_member) {
            member = create(:member_with_membership_app)

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_2_last_year,
                   expire_date: User.expire_date_for_start_date(dec_2_last_year))
            member
          }

          it 'false even if the day is in the list of days to send it' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.send_alert_this_day?(timing, { days: [0] }, paid_expires_today_member)).to be_falsey
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
          expect(described_class.send_alert_this_day?(timing, config, paid_expired_member)).to be_falsey
        end

        it 'false if the day is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(timing, { days: [999] }, paid_expired_member)).to be_falsey
        end

      end

    end


    context 'user is not a member and has no payments: always false' do

      let(:user) { create(:user) }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(timing, config, user)).to be_falsey
      end

      it 'false when the day is not in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(timing, { days: [999] }, user)).to be_falsey
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.mailer_method).to eq :membership_expiration_reminder
  end

end
