#--------------------------
#
# @class ShfDeviseFailureApp
#
# @desc Responsibility: Redirect users to the login page if they try to
#   access a page that requires them to be logged in
#
# @see https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
# @see https://github.com/plataformatec/devise/wiki/Redirect-to-new-registration-(sign-up)-path-if-unauthenticated
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-25
#
#--------------------------


class ShfDeviseFailureApp < Devise::FailureApp


  def route(scope)

    # redirect only if they are a User,  not an Admin (or other type of Devise scope)
    scope.to_sym == :user ? :new_user_session_url : super
  end


  # Override respond to eliminate recall (see the Devise documentation pages for more info)
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end

