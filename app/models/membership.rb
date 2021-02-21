# Individual Membership
#    TODO: abstract common out, create CompanyMembership, DonorMembership
#
class Membership < ApplicationRecord

  belongs_to :user
  # TODO: membership has_many :payments

  # =============================================================================================


  def self.covering_date(date = Date.current)
    where('first_day <= ?', date)
      .where('last_day >= ?', date)
      .order(:last_day)
  end


  def self.for_user_covering_date(user, date = Date.current)
    where(user: user).covering_date(date)
  end


  # @return [ActiveSupport::Duration]
  def self.term_length
    AdminOnly::AppConfiguration.config_to_use.membership_term_length.to_i.days
  end


  def set_first_day_and_last(first_day: Date.current, last_day: first_day + self.class.term_length - 1)
    update(first_day: first_day, last_day: last_day)
  end
end
