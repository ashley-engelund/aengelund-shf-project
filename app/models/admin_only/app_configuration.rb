module AdminOnly

  class AppConfiguration < ApplicationRecord
    # Aggregates discrete data items that are used to configure
    # various aspects of the system (app).

    after_save :check_for_site_meta_image_change

    has_attached_file :chair_signature,
                      url: :url_for_images,
                      default_url: 'chair_signature.png',
                      styles: { standard: ['180x40#'] },
                      default_style: :standard

    has_attached_file :shf_logo,
                      url: :url_for_images,
                      default_url: 'shf_logo.png',
                      styles: { standard: ['257x120#'] },
                      default_style: :standard

    has_attached_file :h_brand_logo,
                      url: :url_for_images,
                      default_url: 'h_brand_logo.png',
                      styles: { standard: ['248x240#'] },
                      default_style: :standard

    has_attached_file :sweden_dog_trainers,
                      url: :url_for_images,
                      default_url: 'sweden_dog_trainers.png',
                      styles: { standard: ['234x39#'] },
                      default_style: :standard

    # The site meta image (used in OpenGraph meta info, etc.)
    # This image _must be_ in the database; that's why there is no default for it
    # and  :validate_attachment_presence is used
    has_attached_file :site_meta_image,
                      url:           :url_for_images

    validates_attachment_presence :site_meta_image


    validates_attachment_content_type :chair_signature, :shf_logo,
                                      :h_brand_logo, :sweden_dog_trainers,
                                      :site_meta_image,
                                      content_type: /\Aimage\/.*(jpeg|png)\z/

    validates_attachment_file_name :chair_signature, :shf_logo,
                                   :h_brand_logo, :sweden_dog_trainers,
                                   :site_meta_image,
                                   matches: [/png\z/, /jpe?g\z/]


    scope :config_to_use, -> { last }


    # Helpful method to get all images for the configuration
    def self.image_attributes
      [:site_meta_image,
       :chair_signature,
       :sweden_dog_trainers,
       :h_brand_logo,
       :shf_logo
      ].freeze
    end


    def image_attributes
      self.class.image_attributes
    end


    # =========================================================================


    private


    def url_for_images
      '/storage/app_configuration/images/:attachment/:hashed_path/:style_:basename.:extension'.freeze
    end


    # If the site_meta_image changed,
    # Have to do this _after_ the attachment has been saved
    def check_for_site_meta_image_change
      update_site_meta_image_dimensions if saved_change_to_attribute?(:site_meta_image_updated_at)
    end

    # Use MiniMagick to recompute the width and height for the site_meta_image
    # only update if the file exists
    def update_site_meta_image_dimensions

      if File.exist?(site_meta_image.path)
        image = MiniMagick::Image.open(site_meta_image.path)
        self.site_meta_image_height = image.height
        self.site_meta_image_width  = image.width
        self.save
      end

    end

  end


end
