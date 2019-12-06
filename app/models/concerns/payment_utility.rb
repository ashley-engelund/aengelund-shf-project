# Common behavior for payments:
#   the most recent completed payment,
#      notes for the most recent payment,
#   start and expiration dates
#   has the term expired, is a payment due, etc.
#
# Using self.class::THIS_PAYMENT_TYPE as the default for a payment type
# means that the payment type for a Payor (e.g. the class that is using this module)
# does not have explictly pass the payment type every single time a method is called.
# Ex:  a User does not have to specify a Membership payment every time; the default
#   payment type for a User is a Membership payment, so that is used as the default
#   (unless a payment type is explicitly given, of course).
#   Likewise, the default payment type for a Company is an H-branding fee payment,
#   so when a Company uses these methods, that does not have to be specified every time.
#
#
module PaymentUtility
  extend ActiveSupport::Concern

  included do

    def most_recent_payment(payment_type = self.class::THIS_PAYMENT_TYPE)
      payments.completed.send(payment_type).order(:created_at).last
    end

    def has_successful_payments?(payment_type = self.class::THIS_PAYMENT_TYPE)
      payments.completed.send(payment_type).any?
    end

    def payment_start_date(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.start_date
    end

    def payment_expire_date(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.expire_date
    end

    def payment_notes(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.notes
    end


    # Has the term expired for this payment type?
    # @return [Boolean] - true if there is no payment expiration date OR if the expiration date is _not_ in the future ( == it is in the past)
    def term_expired?(payment_type = self.class::THIS_PAYMENT_TYPE)
      expires = payment_expire_date(payment_type)
      ((expires.nil?) || !expires.future?)
    end


    # A payment 'should' be made if the payment term has expired
    #      OR
    # the today is within the "should pay cutoff" number of days of the expiration date.
    #   This is the same as calculating
    #      if today is _after_ the (expiration date - should pay cutoff number of days)
    #
    #        let cutoff_date = expiration date - should pay cutoff number of days
    #
    #      so if today is on or after the cutoff date, a payment should be made. (Assuming the term has not expired)
    #
    #  "today" is based on Time.zone.now (@see https://github.com/AgileVentures/shf-project/wiki/Dates-and-Times-and-Timezones-(oh-my!) in the project wiki
    #
    # How close it should be = the "should_pay_cutoff" - this AppConfiguration.config_to_use.payment_too_soon_days
    #   Must convert this to a Duration by using the .days method
    #
    #  Ex: today before the cutoff date, so should_pay_now? will be false
    #    Today is December 1
    #    expiration date is December 31
    #    should_pay_cutoff is 20 days
    #    cutoff_date = Dec 11
    #
    #        Dec. 1    Dec. 11                Dec. 31
    #     -----|---------.--------------------|--------...-->
    #          |         ^                    |
    #        Today       |                expire date
    #                    |
    #            cutoff_date = expired_date - should_pay_cutoff = Dec.11
    #
    #
    # Ex: today is after the cutoff date, so should_pay_now? will be true:
    #    Today is December 18
    #    expiration date is December 31
    #    should_pay_cutoff is 20 days
    #    cutoff_date = Dec 11
    #
    #                 Dec. 11                Dec. 31
    #     ---------------.------|-.---------.|-------...-->
    #                    ^      |            |
    #                    |    Today          expire date
    #                    |
    #            cutoff_date = expired_date - should_pay_cutoff = Dec.10
    #
    # Also see the RSpecs for more examples
    #
    # @param [String] payment_type - the type of payment this is (used to get the expiration date)
    # @param [Duration] should_pay_cutoff - the number of days before a payment
    #    due date that defines when it is "too soon" to pay. Default is from the Application configuration
    #
    # @return [Boolean] - true if the term has expired OR Today is after the cutoff day
    def should_pay_now?(payment_type: self.class::THIS_PAYMENT_TYPE,
                        should_pay_cutoff: AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.days)

      cutoff_date =  has_successful_payments?(payment_type) ? payment_expire_date(payment_type) - should_pay_cutoff : Time.zone.now
      term_expired?(payment_type) || Time.zone.now >= cutoff_date
    end


    # Is it "too early" to pay now?  "too early" is determined by the Application Configuration
    #
    # @param [String] payment_type - the type of payment this is
    # @param [Duration] should_pay_cutoff - Duration (number of days)
    #  FIXME - all usages
    # @return [Boolean] - true only if no payment should be made now
    def too_early_to_pay?(payment_type: self.class::THIS_PAYMENT_TYPE,
                          should_pay_cutoff: AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.days)
      !should_pay_now?(payment_type: payment_type, should_pay_cutoff: should_pay_cutoff)
    end


    # Logic for determining the payment due status.
    # This puts the logic here in one place, and
    # the symbols returned can then easily be used in switch statements (ex: to display different messages, etc.)
    #
    # @return [Symbol] - :past_due | :due | :too_early
    def payment_due_status(payment_type: self.class::THIS_PAYMENT_TYPE,
                           should_pay_cutoff:  AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.days)
      if term_expired?(payment_type)
        :past_due
      elsif too_early_to_pay?(payment_type: payment_type, should_pay_cutoff: should_pay_cutoff)
        :too_early
      else
        :due
      end
    end

  end


  #   - FIXME how to store this date if/when the member is no longer a current member?
  #
  class_methods do

    # TODO should just pass in the entity.  the "id" is an implementation detail that callers should not care about.
    # TODO should just request the payment type as part of the method name.  Passing in the implementation of the payment type (e.g. Payment::PAYMENT_TYPE_BRANDING is an implementation detail that callers shouldn't care about)
    # Note:  Company cannot use this method.  It has a different business rule (i.e. it does not
    # use Today if no previous payment exists.)
    #
    # @param entity_id [Integer] - the id of the entity to get the next payment dates for
    # @param payment_type [Payment::PAYMENT_TYPE_MEMBER | Payment::PAYMENT_TYPE_BRANDING] - the specific type of the payment to look for
    #
    # @return [Array] - the start_date _and_ expire_date for the next payment
    def next_payment_dates(entity_id, payment_type = self::THIS_PAYMENT_TYPE)
      entity = find(entity_id)

      expire_date = entity.payment_expire_date(payment_type)

      if expire_date && expire_date.future?
        start_date = expire_date + 1.day
      else
        start_date = Time.zone.today  # can't use this to determine how many days OVERDUE the membership payment is!
      end

      expire_date = expire_date_for_start_date(start_date)

      [start_date, expire_date]
    end


    # Calculate the expiration date given a start date
    def expire_date_for_start_date(start_date)
      other_date_for_given_date(start_date, is_start_date: true)
    end


    # Helper method for cases where we have the expire date (ex: in tests)
    def start_date_for_expire_date(expire_date)
      other_date_for_given_date(expire_date, is_start_date: false)
    end


    # THIS IS THE KEY RULE ABOUT WHEN PAYMENTS EXPIRE
    #
    # Given a date, get the 'other' date: if we have a start date, get the expiration date.
    # If we have an expiration date, get the start date.
    #
    # The calculation is the same:  it is 1 year - 1 day "away" from the given date,
    # no matter if we are looking into the future (we have a start date
    #  and we and the expire date in the future)
    # or if we are looking backwards to the past (we have an expiration date
    #  and we want to know what the start date was).
    # The only difference is whether we are subtracting 1 year and adding 1 day,
    # or if we add one year and subtract 1 day; the difference is a multiplier of +/- 1.
    #
    # @param [Date] given_date - the date to calculate from
    #
    # @param [Boolean] is_start_date - is given_date the start date? (true by default)
    # @return [Date] - the resulting Date that was calculated
    def other_date_for_given_date(given_date, is_start_date: true)
      multiplier = is_start_date ? 1 : -1
      (given_date + (multiplier * 1.year) - (multiplier * 1.day) )
    end

  end
end
