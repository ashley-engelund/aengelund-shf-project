# Individual Membership
#    TODO: abstract common out, create CompanyMembership, DonorMembership
#
class Membership < ApplicationRecord

  belongs_to :user

  def self.exists_on(date = Date.current)
    where('first_day <= ?', date)
      .where('last_day >= ?', date)
  end


  def self.exists_for_user_on(user, date = Date.current)
    where(user: user).exists_on(date)
  end

  # TODO: membership has_many :payments

  # FIXME get from AppConfiguration
  #     AdminOnly::AppConfiguration.config_to_use.membership_length
  # @return [ActiveSupport::Duration]
  def self.term_length
    AdminOnly::AppConfiguration.config_to_use.membership_term_length.to_i.days
  end


  def set_first_day_and_last(first_day: Date.current, last_day: first_day + self.class.term_length - 1)
    update(first_day: first_day, last_day: last_day)
  end
end
