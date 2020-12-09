#--------------------------
#
# @class UserChecklistManager
#
# @desc Responsibility: Handle all behavior and queries for a UserChecklist associated with a User
#
# 2020-12-07  Business Rule: Everyone must always agree to the membership guidelines,
#   no matter when their term starts/ends, etc.
#   The only limiting factor is when the Membership Guidelines requirement started.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------

class UserChecklistManager

  # @return
  #   true if
  #     1. the user must complete the membership guidelines AND they have completed it
  #     OR
  #     2. the user does _not_ have to complete the guidelines
  #
  #   false if
  #    1. the user must complete the membership guidelines AND they have _not_ completed it
  #
  def self.completed_membership_guidelines_if_reqd?(user)
    guidelines_required = must_complete_membership_guidelines_checklist?(user)
    return true unless guidelines_required
    return true if guidelines_required && completed_membership_guidelines_checklist?(user)
    false
  end

  def self.completed_membership_guidelines_checklist?(user)
    membership_guidelines_list_for(user)&.all_completed?
  end

  # @return [ nil | UserChecklist] - return nil if there aren't any, else return the most recent one
  def self.membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end

  def self.membership_guidelines_agreement_required_now?
    Time.zone.now >= membership_guidelines_reqd_start_date
  end

  # Gets the first incomplete guideline (checklist) for the user.
  # If the user does not have to complete the membership guidelines, return nil.
  # If there are no guidelines, return nil.
  # If there are no incomplete guidelines, return nil.
  #
  # Else return the first uncompleted checklist (since they are given to us here as sorted)
  # @return [Nil | UserChecklist]
  def self.first_incomplete_membership_guideline_section_for(user)
    if must_complete_membership_guidelines_checklist?(user)
      not_completed_guidelines_for(user)&.first
    else
      nil
    end
  end

  # Is this user required to complete a Membership Guideline checklist?
  # true if the membership guidelines checklist is required now
  # false if the membership guidelines checklist is not required right now
  #
  # Although this is simplistic and essentially just calls _membership_guidelines_agreement_required_now?_
  # this is the method that should be used so that if there are any additional checks/requirements
  # that depend on the user, those additional check/requirements can be added here without
  # disrupting or changing anything that needs to check if a user must complete the guidelines (SOLID).
  def self.must_complete_membership_guidelines_checklist?(user)
    raise ArgumentError, "User should not be nil. #{__method__}" if user.nil?

    membership_guidelines_agreement_required_now?
  end

  # Has the user completed 1 or more of the membership guidelines checklist?
  # @return [Boolean]
  def self.completed_some_membership_guidelines_checklist?(user)
    raise ArgumentError, "User should not be nil. #{__method__}" if user.nil?


  end


  # 2020-12-07  Business Rule: Everyone must always agree to the membership guidelines,
  #   no matter when their term starts/ends, etc.
  #   It is only dependent on when the Membership Guidelines requirement was started.
  def self.membership_guidelines_reqd_start_date
    # Could use a class variable here to store/cache ('memoize') this, but reading ENV and parsing the Time.zone is pretty fast.  Plus, this won't happen often.
    if ENV.has_key?('SHF_MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START')
      Time.zone.parse(ENV['SHF_MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START']).to_time
    else
      missing_membership_guidelines_reqd_start_date
    end
  end


  def self.missing_membership_guidelines_reqd_start_date
    Time.zone.now.localtime.yesterday
  end


  def self.completed_guidelines_for(user)
    guidelines_for(user, :completed)
  end


  def self.not_completed_guidelines_for(user)
    # guideline_list.descendants.uncompleted.to_a
    guidelines_for(user, :uncompleted)
  end

  # Make one if it doesn't exist?  NO.  Just return empty list.
  # The selection_block is being used explictly so it's very clear.  (Could have also use yield.)
  def self.guidelines_for(user, completed_method = :completed)
    guideline_list = membership_guidelines_list_for(user) ? membership_guidelines_list_for(user) : {}
    return [] unless guideline_list.present?

    guideline_list.descendants&.send(completed_method).to_a&.sort_by { |kid| "#{kid.ancestry}-#{kid.list_position}" }
  end
end
