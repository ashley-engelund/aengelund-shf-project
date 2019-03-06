# This emails all current members in a company if the h-branding fee
# will be due soon.
#
# The alert is sent before the HBranding license has expired.
#
class HBrandingFeeWillBeDueAlert < CompanyEmailAlert


  # If an H Branding Fee will be due for the company, then
  #   send the alert if today is in the configuration list of days
  #
  # Note that the number of days is based on the _expiration_date_ to remain
  # consistent with using the expiration date as the basis for the number
  # of dates.
  def send_alert_this_day?(timing, config, company)

    if RequirementsForHBrandingFeeWillBeDue.requirements_met?({company: company})

      due = company.branding_expire_date

      day_to_check = self.class.days_today_is_away_from(due, timing)

      send_on_day_number?(day_to_check, config)

    else
      false
    end

  end


  def mailer_method
    :h_branding_fee_will_be_due
  end


  def mailer_args(company)
    [company, company.current_members]
  end

end
