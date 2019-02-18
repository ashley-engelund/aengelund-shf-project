# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'

class ShfApplicationMailerPreview < ActionMailer::Preview

  include PickRandomHelpers

  def app_approved
    ShfApplicationMailer.app_approved(random_shf_app(:accepted))
  end


  def acknowledge_received_no_files_uploaded
    no_uploads = ShfApplication.where.not(id: [UploadedFile.pluck(:shf_application_id)])
    if no_uploads.count == 0
      # create an application with no uploads by removing all the uploads from an app
      new_app = ShfApplication.where(state:'new').first
      new_app.uploaded_files.delete_all
      shf_app_no_uploads = new_app
    else
      shf_app_no_uploads = no_uploads.first
    end
    ShfApplicationMailer.acknowledge_received(shf_app_no_uploads)
  end


  def acknowledge_received_with_files_uploaded
    app_with_uploads = ShfApplication.joins(:uploaded_files).first
    ShfApplicationMailer.acknowledge_received(app_with_uploads)
  end

end
