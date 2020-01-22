# Standardized icons and icon-related helpers to use in the app
#
#
module ShfIconsHelper

  FA_STYLE_DEFAULT = 'fas'
  FA_BLANK = 'blank'
  FA_EDIT = 'edit'
  FA_USER_PROFILE = 'id-card'
  FA_USER_ACCOUNT = 'folder'
  FA_EXTERNAL_LINK = 'external-link-alt'
  FA_COMPLETE_CHECK = 'check-circle'

  # arrows
  FA_ARROW_LEFT = 'arrow-left'
  FA_ARROW_RIGHT = 'arrow-right'
  FA_ARROW_UP = 'arrow-up'
  FA_ARROW_DOWN = 'arrow-down'
  FA_ARROW_CIRCLE_LEFT = 'arrow-circle-left'
  FA_ARROW_CIRCLE_RIGHT = 'arrow-circle-right'
  FA_ARROW_CIRCLE_UP = 'arrow-circle-up'
  FA_ARROW_CIRCLE_DOWN = 'arrow-circle-down'
  FA_ARROW_ALT_CIRCLE_LEFT = 'arrow-alt-circle-left'
  FA_ARROW_ALT_CIRCLE_RIGHT = 'arrow-alt-circle-right'
  FA_ARROW_ALT_CIRCLE_UP = 'arrow-alt-circle-up'
  FA_ARROW_ALT_CIRCLE_DOWN = 'arrow-alt-circle-down'
  FA_LONG_ARROW_ALT_LEFT = 'long-arrow-alt-left'
  FA_LONG_ARROW_ALT_RIGHT = 'long-arrow-alt-right'
  FA_LONG_ARROW_ALT_UP = 'long-arrow-alt-up'
  FA_LONG_ARROW_ALT_DOWN = 'long-arrow-alt-down'


  # Create an entry for each method that you want to define and the icon name it should use
  #  A method will be created for each entry
  #  @example:
  #   for this entry:  { method_name_start: 'complete_check', icon: FA_COMPLETE_CHECK },
  #   this method is created:
  #
  #      def complete_check_icon(html_options: {}, fa_style: FA_STYLE_DEFAULT, text: nil)
  #         get_fa_icon(fa_style, FA_COMPLETE_CHECK, text, html_options)
  #       end
  #
  #  (see the class_eval below).
  #
  METHODS_AND_ICONS = [
      { method_name_start: 'user_profile', icon: FA_USER_PROFILE },
      { method_name_start: 'user_account', icon: FA_USER_ACCOUNT },
      { method_name_start: 'edit', icon: FA_EDIT },
      { method_name_start: 'external_link', icon: FA_EXTERNAL_LINK },
      { method_name_start: 'complete_check', icon: FA_COMPLETE_CHECK },
      { method_name_start: 'blank', icon: FA_BLANK },

      { method_name_start: 'next_arrow', icon: FA_ARROW_RIGHT },
      { method_name_start: 'previous_arrow', icon: FA_ARROW_LEFT },


      # arrows (These use the FontAwesome name to start the method names)
      { method_name_start: 'arrow_left', icon: FA_ARROW_LEFT },
      { method_name_start: 'arrow_right', icon: FA_ARROW_RIGHT },
      { method_name_start: 'arrow_up', icon: FA_ARROW_UP },
      { method_name_start: 'arrow_down', icon: FA_ARROW_DOWN },
      { method_name_start: 'arrow_circle_left', icon: FA_ARROW_CIRCLE_LEFT },
      { method_name_start: 'arrow_circle_right', icon: FA_ARROW_CIRCLE_RIGHT },
      { method_name_start: 'arrow_circle_up', icon: FA_ARROW_CIRCLE_UP },
      { method_name_start: 'arrow_circle_down', icon: FA_ARROW_CIRCLE_DOWN },
      { method_name_start: 'arrow_alt_circle_left', icon: FA_ARROW_ALT_CIRCLE_LEFT },
      { method_name_start: 'arrow_alt_circle_right', icon: FA_ARROW_ALT_CIRCLE_RIGHT },
      { method_name_start: 'arrow_alt_circle_up', icon: FA_ARROW_ALT_CIRCLE_UP },
      { method_name_start: 'arrow_alt_circle_down', icon: FA_ARROW_ALT_CIRCLE_DOWN },
      { method_name_start: 'long_arrow_alt_left', icon: FA_LONG_ARROW_ALT_LEFT },
      { method_name_start: 'long_arrow_alt_right', icon: FA_LONG_ARROW_ALT_RIGHT },
      { method_name_start: 'long_arrow_alt_up', icon: FA_LONG_ARROW_ALT_UP },
      { method_name_start: 'long_arrow_alt_down', icon: FA_LONG_ARROW_ALT_DOWN },

  ]

  METHODS_AND_ICONS.each do |method_info|

    module_eval <<-end_icon_method, __FILE__, __LINE__ + 1
      def #{method_info[:method_name_start]}_icon(html_options: {}, fa_style: FA_STYLE_DEFAULT, text: nil)
        get_fa_icon(fa_style, '#{method_info[:icon]}', text, html_options)
      end
    end_icon_method

    # defines a method that will return the font awesome icon name [String].
    # Ex:  blank_fa_icon_name
    #   will return 'fa-blank'
    module_eval <<-end_icon_name_method, __FILE__, __LINE__ + 1
      def #{method_info[:method_name_start]}_fa_icon_name
        "fa-#{method_info[:icon]}"
      end
    end_icon_name_method
  end


  private

  # Single point of connection (binding) to the FontAwesome icon method
  def get_fa_icon(fa_style, fa_icon, text = nil, html_options = {})
    icon(fa_style, fa_icon, text, html_options)
  end
end
