class PagePolicy < Struct.new(:user, :page)


  def show?
    user_logged_in?
  end


  def index?
    user_logged_in?
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

  def destroy?
    is_admin?
  end

  private
  def user_logged_in?
    !user.nil?
  end


  def is_admin?
    user.admin? if user
  end
end