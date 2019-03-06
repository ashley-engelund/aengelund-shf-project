#--------------------------
#
# @class RequirementsForHBrandingFeeWillBeDue
#
# @desc Responsibility: Knows when an H-Branding Fee WILL BE due for a company
# (= the requirements are met). This is about the upcoming expiration date
# for the H-Branding license.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#        it is the only place that code needs to be touched if the rules for
#        when an H-Branding fee is due are changed.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   2019-03-05
# @file requirements_for_h_branding_fee_will_be_due.rb
#
#--------------------------


class RequirementsForHBrandingFeeWillBeDue < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:company])
  end


  # An H-Branding fee WILL BE due if there are current members in the company
  # AND the branding_licenses IS current.
  def self.requirements_met?(args)
    company = args[:company]
    !company.current_members.empty? && company.branding_license?
  end

end # RequirementsForHBrandingFeeDue
