#!/usr/bin/ruby


#--------------------------
#
# @class SiteMetaInfoDefaults
#
# @desc Responsibility: Provides the default meta info for the site to any
# class/object that asks for it.
#
# This encapsulates the default data; other classes/objects don't need to know
# where it comes from.
#
# TODO: this should get all information from the AppConfiguration so that the administrator can change them as needed.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file site_meta_info_defaults.rb
#
#--------------------------


class SiteMetaInfoDefaults

  FB_APPID_KEY = 'SHF_FB_APPID'


  # These are all class methods
  class << self

    def site_name
      AdminOnly::AppConfiguration.config_to_use.site_name
    end


    def title
      AdminOnly::AppConfiguration.config_to_use.site_meta_title
    end


    def description
      AdminOnly::AppConfiguration.config_to_use.site_meta_description
    end


    def keywords
      AdminOnly::AppConfiguration.config_to_use.site_meta_keywords
    end


    def image_filename
      meta_image.nil? ? '' : meta_image.path
    end


    def image_public_url
      meta_image.nil? ? '' : "#{I18n.t('shf_medlemssystem_url')}#{meta_image.url}"
    end


    def image_type
      meta_content_type = AdminOnly::AppConfiguration.config_to_use.site_meta_image_content_type
      meta_content_type.nil? ? '' : meta_content_type.split('/').last
    end


    def image_width
      AdminOnly::AppConfiguration.config_to_use.site_meta_image_width
    end


    def image_height
      AdminOnly::AppConfiguration.config_to_use.site_meta_image_height
    end


    def og_type
      'website'
    end


    def facebook_app_id
      ENV.fetch(FB_APPID_KEY, nil).to_i
    end


    def twitter_card_type
      'summary'
    end


    # If the value is blank, use the site default returned by the default_method
    #
    def use_default_if_blank(default_method, value)
      value.blank? ? self.send(default_method) : value
    end

    def meta_image
      AdminOnly::AppConfiguration.config_to_use.site_meta_image
    end
  end

end
