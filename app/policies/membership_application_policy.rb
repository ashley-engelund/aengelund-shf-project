class MembershipApplicationPolicy < ApplicationPolicy

  def user_owner_attributes
    [:company_name,
     :company_number,
     :contact_person,
     :company_email,
     :phone_number]
  end


  def attributes_and_status
    user_owner_attributes + [:status]
  end


  # by default, only an admin can change the status attribute
  def permitted_attributes
    if user&.admin?
      attributes_and_status
    else
      user_owner_attributes
    end
  end


  # When a user creates a MembershipApplication, the status is initialized (so can create it)
  def permitted_attributes_for_create
    attributes_and_status
  end

  # the membership_application owner can always see (show) the status
  def permitted_attributes_for_show
    attributes_and_status
  end


  # only an admin can edit the status
  def permitted_attributes_for_edit
    if user&.admin?
      attributes_and_status
    else
      user_owner_attributes
    end
  end


end