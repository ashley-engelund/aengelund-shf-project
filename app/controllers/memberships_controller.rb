class MembershipsController < ApplicationController
  before_action :get_membership_application, only: [:show, :edit, :update]
  before_action :authorize_membership_application, only: [:show, :edit]

  def new
    @membership = MembershipApplication.new
  end

  def create
    @membership = current_user.membership_applications.new(membership_params)
    if @membership.save
      flash[:notice] = 'Thank you, Your application has been submitted'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    authorize MembershipApplication
    @membership_applications = MembershipApplication.all
  end

  def show

  end

  def edit

  end

  def update

      if @membership.update(membership_params)
          flash[:notice] = 'Membership Application
                        successfully updated'
        redirect_to membership_path
      else
        flash[:alert] = 'A problem prevented the membership application from being updated.'
    end

  end

  private
  def membership_params
    params.require(:membership_application).permit(:company_name,
                                                   :company_number,
                                                   :contact_person,
                                                   :company_email,
                                                   :phone_number,
                                                   :status)
  end

  def get_membership_application
    @membership = MembershipApplication.find(params[:id])
  end

  def authorize_membership_application
    authorize @membership
  end
end
