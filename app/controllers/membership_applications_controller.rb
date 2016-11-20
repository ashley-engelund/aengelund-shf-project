class MembershipApplicationsController < ApplicationController
  before_action :get_membership_application, only: [:show, :edit, :update]
  before_action :authorize_membership_application, only: [:update, :show, :edit]


  def new
    @membership_application = MembershipApplication.new
    @uploaded_file = @membership_application.uploaded_files.build
  end


  def create
    @membership_application = current_user.membership_applications.new(membership_application_params)
    if @membership_application.save
      new_upload_file params['uploaded_file'] if params['uploaded_file']

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
    if @membership_application.update(membership_application_params)
      new_upload_file params['uploaded_file'] if params['uploaded_file']

      flash[:notice] = 'Membership Application
                        successfully updated'
      render :show
    else
      flash[:alert] = 'A problem prevented the membership
                       application to be saved'
      redirect_to edit_membership_application_path(@membership_application)
    end
  end


  private
  def membership_application_params
    params.require(:membership_application).permit(*policy(@membership_application || MembershipApplication).permitted_attributes)
  end


  def get_membership_application
    @membership_application = MembershipApplication.find(params[:id])
  end


  def authorize_membership_application
    authorize @membership_application
  end

  def new_upload_file(upload_file_param)
    if upload_file_param['actual_file']
      @uploaded_file = @membership_application.uploaded_files.create(actual_file: upload_file_param['actual_file'])
      if @uploaded_file.valid?
        flash[:notice] = "The file was uploaded: #{@uploaded_file.actual_file_file_name}"
      else
        flash[:error] = @uploaded_file.errors.messages
      end
    end
  end
end
