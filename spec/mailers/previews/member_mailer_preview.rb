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

    new_email = "user-#{Time.now.to_i}@example.com"
    new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    new_co = new_approved_user.shf_application.companies.first

    MemberMailer.h_branding_fee_past_due(new_co, new_approved_user)
  end


  def membership_lapsed

    expires = User.expired_memberships
    if expires.size > 0
      member = expires.last
      MemberMailer.membership_lapsed(member)
    else
      # take a current member and make their term expired!
      current = User.current_members
      if current.size > 0
        member = current.last
        most_recent_payment = member.most_recent_membership_payment
        most_recent_payment.update(expire_date: Date.current - 3)
        MemberMailer.membership_lapsed(member)
      else
        # Uh oh.  you have NO current members.  this will throw an error but not important enough to spend development time on.
      end
    end

    #
  end

end
