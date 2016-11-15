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


  def permitted_attributes
    if user && user.admin?
      attributes_and_status
    else
      user_owner_attributes
    end
  end


  def permitted_attributes_for_create
    attributes_and_status
  end

  def permitted_attributes_for_show
    attributes_and_status
  end


  def permitted_attributes_for_edit
    if user && user.admin?
      attributes_and_status
    else
      user_owner_attributes
    end
  end


end