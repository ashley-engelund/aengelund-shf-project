# Log messages:
#
LOGMSG_APP_UPDATED = 'SHF_application updated'
LOGMSG_APP_UPDATED_CHECKREASON = 'Membership checked because this shf_application was updated: '
LOGMSG_PAYMENT_MADE = 'Payment made'
LOGMSG_PAYMENT_MADE_CHECKREASON = 'Finished checking membership status because this payment was  made: '
LOGMSG_USER_UPDATED = 'User updated'
LOGMSG_USER_UPDATED_CHECKREASON = 'User updated: '

LOGMSG_MEMBERSHIP_GRANTED = 'Membership granted'
LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed'
LOGMSG_MEMBERSHIP_REVOKED = 'Membership revoked'


#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules
#    and requirements.
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
#
# The Observer pattern is used to send notifications (methods) when something
# 'interesting' has changed.  When the MembershipStatusUpdater receives one of these
# notifications, it checks the membership to see if it needs to be changed (updated
# or revoked).  It does this via the :check_requirements_and_act({ user: user })
# method.  (This method is the public interface and main method for all
# Updater classes.)
#
# This check is logged with the ActivityLogger so that anything that happens is
# logged.
#
#
#   MembershipStatusUpdater has the responsibility of checking to see if the membership
#   should be updated or revoked based on the current business rules.
#   Thus all of the business rules can be in just _one place_ (DRY).
#   Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
#   Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
#   Business logic for when a Membership is granted or revoked is encapsulated into 1 class
#   that others are _not_ coupled to.
#   Ditto with logic about Membership terms - whether they have expired or not,
#   how the ending (expire) date is changed, etc.
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
    check_user_and_log(shf_app.user, shf_app, logmsg_user_updated, logmsg_user_updated_start)
  end


  def payment_made(payment)
    check_user_and_log(payment.user, payment, logmsg_payment_made, logmsg_payment_made_finished_checking)
  end


  # FIXME should checklist_completed...  be added?


  def user_updated(user)
    check_user_and_log(user, user, logmsg_user_updated, logmsg_user_updated)
  end


  # end of Notifications received from observed classes

  def revoke_user_membership(user)
    check_user_and_log(user, user, logmsg_user_updated, logmsg_membership_revoked)
  end


  #  This is the main method for checking and changing the membership status.
  #     TODO: for a given date
  #
  def update_membership_status(user)
    today = Date.current

    # permitted next statuses (from the AASM info)
    permitted_next_statuses = user.aasm.states(permitted: true).map(&:name)

    if user.not_a_member? || user.former_member?
      user.start_membership!(date: today) if RequirementsForMembership.satisfied?(user: user)

    elsif user.current_member?
      if RequirementsForRenewal.satisfied?(user: user)
        user.renew!(date: today)
      elsif user.membership_expired_in_grace_period?(today)
        user.start_grace_period!

      elsif user.membership_past_grace_period_end?(today)
        # This shouldn't happen. But just in case the membership status has not been updated for
        # a while and so hasn't transitioned to in_grace_period, we'll do it manually now and then
        # go on and transition to a former member
        user.start_grace_period!
        user.make_former_member!
      end

    elsif user.in_grace_period?
      if user.membership_past_grace_period_end?(today)
        user.make_former_member!
      else
        user.renew!(date: today) if RequirementsForRenewal.satisfied?(user: user)
      end
    end
  end


  def logmsg_user_updated
    LOGMSG_USER_UPDATED
  end

  def logmsg_user_updated_start
    LOGMSG_USER_UPDATED_CHECKREASON
  end

  def logmsg_payment_made
    LOGMSG_PAYMENT_MADE
  end

  def logmsg_payment_made_finished_checking
    LOGMSG_PAYMENT_MADE_CHECKREASON
  end

  def logmsg_membership_granted
    LOGMSG_MEMBERSHIP_GRANTED
  end

  def logmsg_membership_renewed
    LOGMSG_MEMBERSHIP_RENEWED
  end

  def logmsg_membership_revoked
    LOGMSG_MEMBERSHIP_REVOKED
  end

  # -----------------------------------------------------------------------------------------------

  private


  # check the requirements for the user and log information
  def check_user_and_log(user, notification_sender, action_message, reason_check_happened)

    ActivityLogger.open(log_filename, self.class.to_s, action_message, false) do |log|
      # FIXME - this used to only grant or revoke.  But now we also have in_grace_period...
      #   use the state machine
      check_requirements_and_act({ user: user })
      log.record(:info, "#{reason_check_happened}: #{notification_sender.inspect}")
    end
  end


  # This is called if our updater_class requirements have been satisfied.
  # Ex:
  #   if updater_class.update_requirements_checker.satisfied
  # which means that the Membership requirements have been satisfied.
  #
  def update_action(args)
    user = args[:user]
    send_email = args.fetch(:send_email, SEND_EMAIL_DEFAULT)

    # Don't do anything if the membership is already current
    renew_membership(user, send_email) if user.in_grace_period?
    grant_membership(user, send_email) if user.not_a_member? || user.former_member?
  end


  def revoke_update_action(args = {})
    user = args[:user]
    ActivityLogger.open(log_filename, self.class.to_s, logmsg_membership_revoked, false) do |log|

      user.update(member: false) # TODO send any email letting user know they are no longer a member?

      log.record(:info, "#{logmsg_membership_revoked}: #{user.inspect}")
      # future: this makes it easy to record an audit trail here
    end
  end


  def grant_membership(user, send_email)

    ActivityLogger.open(log_filename, self.class.to_s, logmsg_membership_granted, false) do |log|

      previous_membership_status = user.member
      previous_membership_number = user.membership_number

      user.update(member: true, membership_number: user.issue_membership_number) # I don't think a User should be responsible for figuring out the next membership number

      if send_email
        MemberMailer.membership_granted(user).deliver

        if first_membership?(previous_membership_status, previous_membership_number)

          # only send if there are companies that are complete AND branding license payment is current = "good companies" is how they're referred to here
          user_good_cos = user.shf_application&.companies&.select { |co| co.complete? && co.branding_license? }
          has_good_cos = user_good_cos.nil? ? false : user_good_cos.count > 0

          AdminMailer.new_membership_granted_co_hbrand_paid(user).deliver if has_good_cos
        end


      end

      log.record(:info, "#{logmsg_membership_granted}: #{user.inspect}")
    end

  end


  def renew_membership(user, send_email)
    ActivityLogger.open(log_filename, self.class.to_s, logmsg_membership_renewed, false) do |log|
      # MemberMailer.membership_renewed(user).deliver if send_email  FIXME
      log.record(:info, "#{logmsg_membership_renewed}: #{user.inspect}")
    end
  end


  def first_membership_and_a_good_company?(user)
    first_membership?(user.member, user.membership_number) && user.in_at_least_one_co_in_good_standing?
  end


  def first_membership?(previous_membership_status = true, previous_membership_number = nil)
    previous_membership_number.nil? && !(previous_membership_status)
  end
end
