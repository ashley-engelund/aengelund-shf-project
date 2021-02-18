#--------------------------
#
# @class MembershipsManager
#
# @desc Responsibility: manage memberships for a User; respond to queries about Memberships
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2/16/21
#
#--------------------------

class MembershipsManager

  MOST_RECENT_MEMBERSHIP_METHOD = :last_day


  def self.most_recent_membership_method
    MOST_RECENT_MEMBERSHIP_METHOD
  end


  # @return [Duration] - the number of days that a Member can renew early
  def self.days_can_renew_early
    AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.to_i.days
  end


  # @return [Duration] - the number of days after the end of a membership that a user can renew
  def self.grace_period
    AdminOnly::AppConfiguration.config_to_use.membership_expired_grace_period.to_i.days
  end


  def self.get_next_membership_number
    # FIXME
  end


  # ---------------------------------------------------------------------------------

  # @return [nil | Membership] - nil if no Memberships, else the one with the latest last day
  def most_recent_membership(user)
    memberships = user.memberships
    return nil if memberships.empty?

    memberships.order(most_recent_membership_method)&.last
  end


  def most_recent_membership_method
    self.class.most_recent_membership_method
  end


  def most_recent_membership_last_day(user)
    most_recent_membership(user)&.last_day
  end


  # Does a user have a membership that has not expired as of the given date
  # Note this does not determine if payments were made, requirements were met, etc.
  def has_membership_on?(user, this_date)
    return false if this_date.nil?

    Membership.exists_for_user_on(user, this_date).exists?
  end


  # The membership term has expired, but are they still within a 'grace period'?
  def membership_in_grace_period?(user,
                                  this_date = Date.current,
                                  membership: most_recent_membership(user))
    return false if membership.nil?

    date_in_grace_period?(this_date, last_day: membership.last_day)
  end


  def date_in_grace_period?(this_date = Date.current,
                            last_day: Date.current,
                            grace_days: grace_period)
      this_date > last_day &&
      this_date <= (last_day + grace_days)
  end


  # @return [Integer]
  def grace_period
    self.class.grace_period
  end


  def can_renew_today?(user)
    can_renew_on?(user, Date.current)
  end


  # This just checks the dates about renewal, not any requirements for renewing a membership.
  def can_renew_on?(user, this_date = Date.current)
    return false unless has_membership_on?(user, this_date)

    last_day = most_recent_membership_last_day(user)
    if this_date <= last_day
      this_date >= (last_day - days_can_renew_early)
    else
      membership_in_grace_period?(user, this_date)
    end
  end


  # @return [Integer]
  def days_can_renew_early
    self.class.days_can_renew_early
  end
end
