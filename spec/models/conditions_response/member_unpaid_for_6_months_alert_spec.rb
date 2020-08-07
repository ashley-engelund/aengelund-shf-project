require 'rails_helper'


RSpec.describe MemberUnpaidOver6MonthsAlert, type: :model do

  let(:subject) { described_class.instance }

  # don't write anything to the log
  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe 'Unit tests' do

    describe '.add_entity_to_list?(user) if the RequirementsForMemberUnpaidMoreThanXMonths is met' do

      it 'RequirementsForMemberUnpaidMoreThanXMonths is not satisfied' do
        mock_member = instance_double("User")
        allow(RequirementsForMemberUnpaidMoreThanXMonths).to receive(:requirements_met?).and_return(false)

        expect(subject.add_entity_to_list?(mock_member)).to be_falsey
      end


      it 'RequirementsForMemberUnpaidMoreThanXMonths is satisfied' do
        mock_member = instance_double("User")
        allow(RequirementsForMemberUnpaidMoreThanXMonths).to receive(:requirements_met?).and_return(true)

        expect(subject.add_entity_to_list?(mock_member)).to be_truthy
      end

    end


    describe 'recipients' do

      it "is hardcoded to use ENV['SHF_MEMBERSHIP_EMAIL']" do
        mock_membership_admin = instance_double("User")

        expect(User).to receive(:new)
                            .with(first_name: 'Membership', last_name: 'Administrator',
                                  password: anything,
                                  email: ENV['SHF_MEMBERSHIP_EMAIL'])
                            .and_return(mock_membership_admin)

        expect(subject.recipients).to match_array([mock_membership_admin])
      end
    end


    it '.mailer_method' do
      expect(subject.mailer_method).to eq :member_unpaid_over_x_months
    end


    it '.mailer_args' do
      mock_member = instance_double("User", member: true)
      allow(subject).to receive(:entities_list).and_return([mock_member])

      mock_admin = instance_double("User", admin: true)
      expect(subject.mailer_args(mock_admin)).to match_array([mock_admin, [mock_member], 6])
    end
  end


  describe 'Integration tests' do
    let(:mock_membership_admin) { instance_double("User") }
    let(:mock_overdue1) { instance_double("User") }
    let(:mock_overdue2) { instance_double("User") }
    let(:mock_overdue3) { instance_double("User") }

    let(:member_fee_due) { DateTime.new(2020, 1, 27) } # just ensure that this is more than 6 months past due


    context 'timing is :day_of_month' do
      let(:timing) { :day_of_month }

      context 'config: {days: [1, 15]}' do
        let(:config) { { days: [1, 15] } }
        let(:condition) { build(:condition, timing: timing, config: config) }

        before(:each) do
          allow(User).to receive(:new)
                             .and_return(mock_membership_admin)

          allow(subject).to receive(:entities_to_check)
                                .and_return([mock_overdue1,
                                             mock_overdue2,
                                             mock_overdue3])
        end


        context 'there are members > 6 months past due' do

          before(:each) do
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue1, num_months: anything)
                        .and_return(true)
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue2, num_months: anything)
                        .and_return(false)
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue3, num_months: anything)
                        .and_return(true)
          end


          context 'today is the 15th of the month' do
            let(:testing_today) { member_fee_due + 6.months + 5.days } # This is more than 6 months after

            it 'sends email to the membership email address with the list of past due members' do
              expect(subject).to receive(:send_alert_this_day?)
                                     .with(timing, config)
                                     .and_call_original

              expect(subject).to receive(:send_email)
                                     .with(mock_membership_admin,
                                           mock_log,
                                           [mock_overdue1, mock_overdue3])

              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end
            end
          end

        end


        context 'there are no members > 6 months past due' do
          before(:each) do
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue1, num_months: anything)
                        .and_return(false)
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue2, num_months: anything)
                        .and_return(false)
            allow(RequirementsForMemberUnpaidMoreThanXMonths)
                .to receive(:requirements_met?)
                        .with(user: mock_overdue3, num_months: anything)
                        .and_return(false)
          end

          context 'today is the 15th of the month' do
            let(:testing_today) { member_fee_due + 6.months + 5.days } # This is more than 6 months after

            it 'no email is sent' do
              expect(subject).not_to receive(:send_email)

              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end
            end

          end

        end
      end

    end

  end

end
