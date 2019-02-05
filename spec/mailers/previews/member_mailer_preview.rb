# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'

class MemberMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def membership_granted
    approved_app = ShfApplication.where(state: :accepted).first
    MemberMailer.membership_granted(approved_app.user)
  end


  def membership_expiration_reminder
    member = User.where(member: true).first
    MemberMailer.membership_expiration_reminder(member)
  end


  def h_branding_fee_past_due

    new_email         = "user-#{Time.now.to_i}@example.com"
    new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    new_co            = new_approved_user.shf_application.companies.first

    MemberMailer.h_branding_fee_past_due(new_co, new_approved_user)
  end


  def app_no_uploaded_files

    # create a new user with a brand new application (that has no uploaded files)
    if @new_approved_user.nil?
      new_email = "sussh-#{DateTime.now.strftime('%Q')}@example.com"

      @new_approved_user = User.create(first_name:   'Suss',
                                       last_name:    'Hundapor',
                                       password:     'whatever',
                                       email:        new_email,
                                       member_photo: nil,
      )
      ShfApplication.new(user: @new_approved_user)
    end

    MemberMailer.app_no_uploaded_files @new_approved_user

  ensure
    User.delete(@new_approved_user.id) unless @new_approved_user.nil?
  end

end
