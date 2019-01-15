# This emails all current members in a company if the h-branding fee is past due.
#
#
class HBrandingFeePastDueAlert < CompanyEmailAlert


  # If an H Branding Fee is due for the company, then
  #   send the alert if today is in the configuration list of days
  #
  def send_alert_this_day?(timing, config, company)

    if RequirementsForHBrandingFeeDue.requirements_met?({company: company})

      day_to_check = self.class.days_today_is_away_from(company.next_hbranding_payment_due_date, timing)

      send_on_day_number?(day_to_check, config)

    else
      false
    end

  end


  def mailer_method
    :h_branding_fee_past_due
  end


  def mailer_args(company)
    [company, company.current_members]
  end

end
