#--------------------------
#
# @class CustomDeviseFailApp
#
# @desc Responsibility: Redirects users to the login page on Warden authorization failures
# See
# https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-05-11
#
# @file custom_devise_fail_app.rb
#
#--------------------------
class CustomDeviseFailApp < Devise::FailureApp

  # Redirect users to the login path on a Warden authorization failure
  def redirect_url
    new_user_session_path
  end

end
