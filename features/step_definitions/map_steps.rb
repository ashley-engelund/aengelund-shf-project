# Map steps

MAP_ID = 'map'
MAP_XP = "//*[@id='#{MAP_ID}']"
SEARCH_NEAR_ME_DIV_ID = 'searchNearMe'
SEARCH_NEAR_ME_CHECKBOX_ID = 'searchNearMeCheckbox'
SEARCH_NEAR_ME_CHECKBOX_XP = MAP_XP + "//*[@id='#{SEARCH_NEAR_ME_DIV_ID}']/*[@id='#{SEARCH_NEAR_ME_CHECKBOX_ID}']"


# This is not possible.  Google Maps does not provide ids for all elements.
#And "I should see the element with id {capture_string} on the map" do |  capture_string |
#  print(page.html)
#  expect(page).to find(:xpath, map_element_xpath(capture_string), visible:false )
#end

def map_element_xpath(element_id)
  MAP_XP + "//*[@id='#{element_id}']"
end

# FIXME is this possible given that GoogleMaps does not provide IDs for the map control elements?
And "the search near me checkbox on the map should be {action}ed" do | action |
  expect(page.send(action, id: SEARCH_NEAR_ME_CHECKBOX_ID)).to be_truthy
end


# FIXME is this possible given that GoogleMaps does not provide IDs for the map control elements?
And "I {action} the search near me checkbox on the map" do | action |
  page.send(action,  id: 'searchNearMeCheckbox')
end



# TODO: not sure I can use this.
And(/my location is (\d+)\.(\d+), (\d+)\.(\d+)/) do |lat_num1, lat_num2, long_num1, long_num2|
  latitude = lat_num1 + int_to_decimal_part(lat_num2)
  longitude = long_num1 + int_to_decimal_part(long_num2)


end

# convert an integer to a matissa (the part to the right of the decimal)
# the largest numeral (left-most) of the integer becomes the first numeral
# after the decimal.
#  Ex:  12345 => 0.12345
#  Ex:  3 => 0.3
def int_to_decimal_part(orig_int)
  num_digits = orig_int.digits.size
  (orig_int * (10.pow(-(num_digits))).to_f).round(num_digits)
end


# TODO how to accomplish this?  Is it possible to change the Chrome settings for this?
And "my location is not available" do
  pending
end

