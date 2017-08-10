# Preview all emails at http://localhost:3000/rails/mailers/shf_mailer

# This is not a test or specification.  This will be run when the system is running
# and the above url is used. @see http://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails

class ShfMailerPreview < ActionMailer::Preview


  def reset_password_instructions
    ShfMailer.reset_password_instructions(User.second, "faketoken", {})
  end



  def accept

    member_app = User.second.membership_applications.last

    #ShfMailer.accept(MembershipApplication.find(7))
    ShfMailer.accept(member_app)
  end



end
