class HighVoltagePolicy < ApplicationPolicy


  def show?
    user?
  end


  def index?
    user?
  end


  def new?
    is_admin?
  end

  def create?
    new?
  end

  def update?
    is_admin?
  end


  def edit?
    update?
  end

  private
  def is_admin?
    @user.admin? if @user
  end
end