class UploadedFilePolicy < ApplicationPolicy

  def index?
    can_see_page_for_the_user?
  end

  def new?
    can_see_page_for_the_user?
  end

  def edit?
    can_see_page_for_the_user? && admin_or_owner?
  end

  def show?
    admin_or_owner?
  end

  def create?
    not_a_visitor?
  end

  def destroy?
    admin_or_owner?
  end


  private

  def can_see_page_for_the_user?
    user.admin? || (not_a_visitor? && user == record)
  end

end
