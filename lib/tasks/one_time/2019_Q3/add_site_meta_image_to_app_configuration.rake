# Add the image Sveriges_hundforetagare_banner_sajt.jpg as the
# site meta_image file attachment to the latest Application Configuration

namespace :shf do
  namespace :one_time do

    desc 'Set site_meta_image to Sveriges_hundforetagare_banner_sajt.jpg for latest AppConfig'
    task set_site_meta_image: :environment do |this_task|

      IMAGE_FNAME = 'Sveriges_hundforetagare_banner_sajt.jpg'

      ActivityLogger.open(LogfileNamer.name_for(this_task.to_s), 'OneTimeRakeTask', this_task.to_s) do |log|

        log.info("Setting the Application Configuration (config_to_use) site_meta_image to #{IMAGE_FNAME}.")

        app_config = AdminOnly::AppConfiguration.config_to_use

        meta_image_file = File.open(File.join(__dir__, IMAGE_FNAME))
        app_config.site_meta_image = meta_image_file
        meta_image_file.close

        app_config.save!
        app_config.update_site_meta_image_dimensions # ensure the dimensions are computed and saved

        log.info("The site_meta_image has been set to #{IMAGE_FNAME}.")
      end

    end

  end
end
