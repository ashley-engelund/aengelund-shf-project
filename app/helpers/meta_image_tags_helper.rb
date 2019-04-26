#!/usr/bin/ruby

require 'mini_magick'
require 'site_meta_info_defaults'


#--------------------------
#
# @module MetaImageTagsHelper
#
# @desc Responsibility: Set meta information for images (for a page).
# If no specific value is provided for a tag, information is looked up in
# locale files. Falls back to site defaults if an entry is not found in
# the locale files.
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

  LOCALE_IMAGE_KEY = 'meta.default.image_src'
  LOCALE_FILENAME = "#{LOCALE_IMAGE_KEY}.filename"
  LOCALE_IMAGE_TYPE = "#{LOCALE_IMAGE_KEY}.image_type"
  LOCALE_WIDTH = "#{LOCALE_IMAGE_KEY}.width"
  LOCALE_HEIGHT = "#{LOCALE_IMAGE_KEY}.height"

  # TODO: handle more than 1 image for a page. get possible comma sep. list from locale
  #
  # Return a Hash with meta tags for the page images.
  # If no filename is provided or if it doesn't exit,
  #   use the filename given in the locale file or the default.
  def page_meta_image_tags(full_image_filepath = nil)

    if full_image_filepath && File.exist?(full_image_filepath)

      # make a temp. copy of the file just to be safe
      image = MiniMagick::Image.new(full_image_filepath)

      meta_image_tags(full_image_filepath,
                      image.type.downcase,
                      width:  image.width,
                      height: image.height)

    else
      fallback_to_locale_or_default_image
    end

  end


  # Look up the image file information in the locale file  under the
  # LOCALE_IMAGE_KEY key.
  # If the required info isn't in the locale file, use the default meta image.
  def fallback_to_locale_or_default_image
    all_image_info_in_locale? ? meta_image_from_locale : meta_default_image_tags
  end


  # Use the image file given in the locale file: the file name, type, height, and width.
  def meta_image_from_locale
    image_fn = t(LOCALE_FILENAME)

    meta_image_tags(image_fn,
                    t(LOCALE_IMAGE_TYPE).downcase,
                    width:  t(LOCALE_WIDTH),
                    height: t(LOCALE_HEIGHT))
  end


  # Create the meta image tags for a page using the default image and tags
  def meta_default_image_tags

    meta_image_tags(SiteMetaInfoDefaults.image_filename,
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
  # @param image_fn [String] - the image asset filename
  # @param [String] image_type -  the string representing the image type, to tell OpenGraph the type (e.g. 'jpeg', 'png', etc.)
  # @param [Integer] width - width of the image if known; will be used if given
  # @param [Integer] height - height of the image if known; will be used if given
  #
  # @return [Hash] - hash with keys set for the image and OG tags
  def meta_image_tags(image_fn, image_type, width: 0, height: 0)

    image_url = asset_url(image_fn)

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


  private

  def all_image_info_in_locale?
    required_entries = [LOCALE_FILENAME, LOCALE_IMAGE_TYPE, LOCALE_WIDTH, LOCALE_HEIGHT]

    I18n.exists?(LOCALE_IMAGE_KEY) &&
        required_entries.inject(true){|bool, image_info| bool && I18n.exists?(image_info)}
  end

end
