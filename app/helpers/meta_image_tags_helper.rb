#!/usr/bin/ruby

require 'mini_magick'
require 'site_meta_info_defaults'


#--------------------------
#
# @module MetaImageTagsHelper
#
# @desc Responsibility: Set meta information for images (for a page).
# If no specific value is provided for a tag, information is looked up in
# the application configuration.
#
# This encapsulates all of the logic and info needed to set image tags.
# It's complicated enough to justify pulling out into its own module.
#
#  NOTE: this must be called from a *View* so that Sprockets is used to get the
#  fingerprinted asset url.  Sprockets will _only_ be called and work from a View.
#
# ImageMagick is used to get the image type, width, and height.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-04-25
#
# @file meta_image_tags_helper.rb
#
#--------------------------
module MetaImageTagsHelper

  # TODO: handle more than 1 image for a page. get possible comma sep. list from locale
  #
  # Return a Hash with meta tags for the page images.
  # If no attachment_image is provided or if it doesn't exist,
  #   use the SiteDefault meta image info
  #
  # @param [String] attachment_image - the attachment_image (responds to :path and :url)
  #     (e.g. a Paperclip attachment)
  #
  def page_meta_image_tags(attachment_image = nil)

    # The file must exist in public/storage and respond to :path and :url
    if attachment_image &&
        attachment_image.respond_to?(:path) && attachment_image.respond_to?(:url) &&
        File.exist?(attachment_image.path)

      # make a temp. copy of the file just to be safe
      image = MiniMagick::Image.new(attachment_image.path)

      meta_image_tags(attachment_image.url,
                      image.type.downcase,
                      width:  image.width,
                      height: image.height)
    else
      use_site_defaults
    end

  end


  def use_site_defaults
    meta_image_tags(SiteMetaInfoDefaults.image_public_url,
                    SiteMetaInfoDefaults.image_type,
                    width:  SiteMetaInfoDefaults.image_width,
                    height: SiteMetaInfoDefaults.image_height)
  end


  # Given the image filename for an image (ex: 'Sveriges_hundforetagare_banner_sajt.jpg')
  # create the right meta tags for that image:
  #   - image_src
  #   - og:image (including the type, height, and width)
  #
  # I use keyword params for width and height because I personally have to
  # look up param order whenever there's both a width and height to see what
  # order is wanted. Keywords solve that.
  #
  # TODO: allow multiple images to be set for og.image
  #
  # @param image_url [String] - the publicly available URL for the file
  # @param [String] image_type -  the string representing the image type, to tell OpenGraph the type (e.g. 'jpeg', 'png', etc.)
  # @param [Integer] width - width of the image if known; will be used if given
  # @param [Integer] height - height of the image if known; will be used if given
  #
  # @return [Hash] - hash with keys set for the image and OG tags
  def meta_image_tags(image_url, image_type, width: 0, height: 0)

    { image_src: image_url,
      og:        {
          image: {
              _:      image_url,
              type:   "image/#{image_type}",
              width:  width,
              height: height
          }
      }
    }
  end

end
