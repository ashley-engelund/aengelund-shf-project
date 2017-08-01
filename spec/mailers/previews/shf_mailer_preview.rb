# Preview all emails at http://localhost:3000/rails/mailers/shf_mailer

class ShfMailerPreview < ActionMailer::Preview


  def reset_password_instructions
    ShfMailer.reset_password_instructions(User.second, "faketoken", {})
  end


end
