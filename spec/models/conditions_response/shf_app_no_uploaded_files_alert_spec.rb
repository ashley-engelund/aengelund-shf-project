require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe ShfAppNoUploadedFilesAlert do

  let(:nov30) { Time.utc(2018, 11, 30) }
  let(:dec1)  { Time.utc(2018, 12, 1) }
  let(:dec7)  { Time.utc(2018, 12, 7) }


  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:condition) { create(:condition, :after, config: { days: [1, 7] }) }

  let(:config) { { days: [1, 7] } }

  let(:timing) { ShfAppNoUploadedFilesAlert::TIMING_AFTER }


  describe '.send_alert_this_day?(config, user)' do

    APP_STATE_STILL_NEEDING_UPLOADS = [:new, :under_review, :waiting_for_applicant]
    OTHER_STATES = ShfApplication.all_states - APP_STATE_STILL_NEEDING_UPLOADS

    it 'false if no application' do
      expect(described_class.instance.send_alert_this_day?(timing, config, user)).to be_falsey
    end


    describe "application state not one of #{APP_STATE_STILL_NEEDING_UPLOADS}" do
      APP_STATE_STILL_NEEDING_UPLOADS.each do | app_state |

        let(:applicant) do
          u = create(:user_with_membership_app)
          u.shf_application.state = app_state
          u
        end

        it 'false even if today is in the list of alert days' do
          # ensure that the updated_at date is Nov 30
          Timecop.freeze(nov30) do
            applicant
          end

          Timecop.freeze(dec1) do
            expect(Date.current - applicant.shf_application.updated_at.to_date).to eq 1
            expect(described_class.instance.send_alert_this_day?(timing, { days: [1] }, applicant)).to be_falsey
          end

        end
      end
    end

    describe "application state IS one of  #{APP_STATE_STILL_NEEDING_UPLOADS}" do

      APP_STATE_STILL_NEEDING_UPLOADS.each do | app_state |

        let(:applicant) do
          u = create(:user_with_membership_app)
          u.shf_application.state = app_state
          u
        end

        it 'false if today - shf_app.updated_at date is not in the list of days' do
          # ensure that the updated_at date is Nov 30
          Timecop.freeze(nov30) do
            applicant
          end

          Timecop.freeze(dec1) do
            expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, applicant)).to be_falsey
          end
        end

        it 'true if today - shf_app.updated_at date IS in the list of days' do
          # ensure that the updated_at date is Nov 30
          Timecop.freeze(nov30) do
            applicant
          end

          alert_days = [ dec1, dec7 ]
          alert_days.each do | alert_date |
            Timecop.freeze(alert_date) do
              expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
            end

          end
        end
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.instance.mailer_method).to eq :app_no_uploaded_files
  end

end
