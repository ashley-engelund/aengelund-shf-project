# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'

class MemberMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def membership_granted
    approved_app = ShfApplication.where(state: :accepted).first
    MemberMailer.membership_granted(approved_app.user)
  end


  def membership_expiration_reminder
    member = User.where(member: true).first
    MemberMailer.membership_expiration_reminder(member)
  end


  def h_branding_fee_past_due

    new_email         = "user-#{Time.now.to_i}@example.com"
    new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    new_co            = new_approved_user.shf_application.companies.first

    MemberMailer.h_branding_fee_past_due(new_co, new_approved_user)
  end


  def membership_lapsed
    new_email         = "user-#{Time.now.to_i}@example.com"
    new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    start_date = Date.current - 400

    FactoryBot.create(:membership_fee_payment,
           :successful,
           user:        new_approved_user,
           start_date:  start_date,
           expire_date: User.expire_date_for_start_date(start_date) )

    MemberMailer.membership_lapsed(new_approved_user)

  end

end
