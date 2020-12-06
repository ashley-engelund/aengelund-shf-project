class UploadedFilePolicy < ApplicationPolicy

  def index?
    user.admin? || (not_a_visitor? && user == record)
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

end
