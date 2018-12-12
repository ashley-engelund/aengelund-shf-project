class MembershipExpireAlert < UserEmailAlert

  def self.send_alert_this_day?(config, user, this_date)

    return false unless user.membership_current_as_of?(this_date)

    days_until_expiry = days_since(this_date, user.membership_expire_date)

    send_on_day_number?(days_until_expiry, config)
  end


  def self.mailer_method
    :membership_expiration_reminder
  end

end
