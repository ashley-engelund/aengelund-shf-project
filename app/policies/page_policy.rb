class PagePolicy
  def initialize(user, _page)
    @user = user
  end

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

  private
  def user_logged_in?
    !@user.nil?
  end
  def is_admin?
    @user.admin? if @user
  end
end