
#--------------------------
#
# @class CustomDeviseFailApp
#
# @desc Responsibility: Redirects users to the login page on a Warden auth failure
#
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-05-11
#
# @file custom_devise_fail_app.rb
#
#--------------------------
class CustomDeviseFailApp < Devise::FailureApp

  # Where users will be redirected on any Warden failure
  # = login path
  def redirect_url
    new_user_session_path
  end


  # Need to override this so that warden recall is not involved (per Devise
  # FailuraApp instructions:
  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated)
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

end
