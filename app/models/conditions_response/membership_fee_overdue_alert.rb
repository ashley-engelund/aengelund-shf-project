# This emails a member _after_ their membership_fee payment is due.
# It warns them that their membership_fee payment is overdue.
#
class MembershipFeeOverdueAlert < UserEmailAlert


  def self.send_alert_this_day?(timing, config, user)

    return false unless user.has_approved_shf_application?

    day_to_check = days_today_is_away_from(user.membership_expire_date, timing)

    send_on_day_number?(day_to_check, config)
  end


  def self.mailer_method
    :membership_payment_due
  end

end
