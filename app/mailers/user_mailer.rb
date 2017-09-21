class UserMailer < ShfMailer

  # TODO can this be accomplished with a simple callback?  before_action:

  # Set the instance vars before calling each Devise method via super
  %w(
      confirmation_instructions
      reset_password_instructions
      unlock_instructions
      email_changed
      password_change
      ).each do |method|

    define_method(method) do |resource, *args|
      set_greeting_name(resource)
      set_recipient_email(resource)
      super(resource, *args)
    end

  end


end
