#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules and requirements.
#  - gets notifications from events in the system and does what is needed with them to
#    update the status of memberships for people in the system
#
#    This is a Singleton.  Only 1 is needed for the system.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/21/17
# @file membership_status_updater.rb
#
# Goals with this PR:
#   - show how the Observer pattern can and should be used to keep Membership status up to date
#   - Single Responsibilty:  each class should have a *single* responsibility
#     - Currently, the User class is waaay too big!  it has too many responsibilities.
#       This moves the "update membership status based on the business rules"
#       responsibility out of it into the MembershipStatusUpdater class
#
# The Observer pattern can and should also be used to update the company visibility:
#   CompanyVisibilityUpdater has the responsibility of checking to see if the company should currently be visible
#     based on the current business rules.  Thus all of the business rules are just in _one place_.
#     Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
# Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
#   Business logic for when a Membership is granted or revoked is encapsulated into 1 class that others are _not_ coupled to
#   Ditto with logic about Membership terms - whether they have expired or not, how the ending (expire) date is changed, etc.
#
#    - adding things that need to notify observers is easy:
#      1. include Observable
#      2. after_initialization :add_observers
#      3. def add_observers (and add the observers in that method)
#      4. where appropriate, let the observerse know a change has been made so they can do their thing
#
#
# Payments should split into a Factory and subclasses (MembershipFeePayment, BrandingFeePayment)
#
#--------------------------


class MembershipStatusUpdater < AbstractUpdater

  SEND_EMAIL_DEFAULT = true


  def self.update_requirements_checker
    RequirementsForMembership
  end


  def self.revoke_requirements_checker
    RequirementsForRevokingMembership
  end


  #--------------------------
  # Notifications received from observed classes:
  # - - -
  # Could set up some more generalized meta-code to get information from notifications sent,
  # but for now this is simple to maintain because it is explicit.
  #

  def shf_application_updated(shf_app)
    ActivityLogger.open(log_filename, self.class.to_s, 'shf_application updated', false) do |log|

      check_requirements_and_act({ user: shf_app.user })

      log.record(:info, "membership checked because this shf_application was updated: #{shf_app.inspect}")
    end
  end


  def payment_made(payment)
    ActivityLogger.open(log_filename, self.class.to_s, 'payment made', false) do |log|

      check_requirements_and_act({ user: payment.user })

      log.record(:info, "finished checking membership status because this payment was  made: #{payment.inspect}")
    end
  end


  def user_updated(user)

    ActivityLogger.open(log_filename, self.class.to_s, 'user updated', false) do |log|

      check_requirements_and_act({ user: user })

      log.record(:info, "User updated: #{user.inspect}")
    end

  end


  private

  def update_action(args)
    user = args[:user]
    send_email = args.fetch(:send_email, SEND_EMAIL_DEFAULT)

    ActivityLogger.open(log_filename, self.class.to_s, "membership granted", false) do |log|

      user.update(member: true, membership_number: user.issue_membership_number) # I don't think a User should be responsible for figuring out the next membership number
      MemberMailer.membership_granted(user).deliver if send_email

      log.record(:info, "Membership granted for #{user.inspect}")
    end

  end


  def revoke_update_action(args = {})
    user = args[:user]
    ActivityLogger.open(log_filename, self.class.to_s, "membership revoked", false) do |log|
      user.update(member: false)
      log.record(:info, "Membership revoked for #{user.inspect}")
      # future:  this makes it easy to record an audit trail here
    end
  end


end # MembershipStatusUpdater

