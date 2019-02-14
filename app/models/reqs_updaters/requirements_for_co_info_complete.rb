#--------------------------
#
# @class RequirementsForCoInfoComplete
#
# @desc Responsibility: Knows when the a company has all required information
#       a.k.a. is "complete" (= the requirements are met)
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#        it is the only place that code needs to be touched if the rules for
#        when the all the required information for a company is complete
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   2019-02-06
# @file requirements_for_co_info_complete.rb
#
#--------------------------


class RequirementsForCoInfoComplete < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:company])
  end


  # the company has a name and every address for it has a Region
  def self.requirements_met?(args)
    company = args[:company]

    !( company.name.blank? || company.missing_region? )
  end

end # RequirementsForCoInfoComplete
