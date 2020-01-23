#--------------------------
#
# @class RequirementsForMembership
#
# @desc Responsibility: Knows what the membership requirements are for a User
#       - Given a user, it can respond true or false if membership requirements are met.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_for_membership.rb
#
#--------------------------


class RequirementsForMembership < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end



  # TODO hardcoded completed_membership_guidelines_checklist for now. Could be more generalized later with info from AppConfiguration, etc.
  def self.requirements_met?(args)
    user = args[:user]

    # FIXME what about current members?  They do not need to agree to the checklist until they renew.
    # Anyone that is not a member on the 'start requiring membershp guidelines date'
    # must complete the checklist as a membership requirement.
    # Anyone that is already a member on the "start requiring membership guidelines date"
    #  does NOT need to comlete the checklist -- until they renew.
    #
    user.has_approved_shf_application? &&
        user.completed_membership_guidelines_checklist? &&
        user.membership_current?
  end

end # RequirementsForMembership
