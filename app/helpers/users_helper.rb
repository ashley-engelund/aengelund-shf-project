module UsersHelper

  def most_recent_login_time user
    user.current_sign_in_at.blank? ? user.last_sign_in_at : user.current_sign_in_at
  end

  def most_recent_login_ip user
    user.current_sign_in_ip.blank? ? user.last_sign_in_ip : user.current_sign_in_ip
  end

end