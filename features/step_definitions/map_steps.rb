# map steps

And("I should{negate} see the map") do |negated|
  wait_for_ajax
  expect(page).send (negated ? :not_to : :to), have_css('#map')
end

And("I should{negate} see the Show Near Me control on the map") do |negated|
  wait_for_ajax
  expect(page).send (negated ? :not_to : :to), have_css('#show-near-me')
end

And("I should{negate} see markers on the map") do |negated|
  wait_for_ajax
  expect(page).send (negated ? :not_to : :to), have_css('#show-near-me')
end


And("I should see {digits} company markers on the map") do |n|
  # xpath for markers on the map =
  # //*[@id="map"]/div/div/div[1]/div[3]/div/div[3]/*/img
  expect(page).to have_xpath('//*[@id="map"]/div/div/div[1]/div[3]/div/div[3]/*/img',
                             visible: false,
                             count:   n)
end

#----------------------------------------------------------------------------------
# from @url https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until finished_all_ajax_requests?
  end
end


def finished_all_ajax_requests?
  page.evaluate_script('jQuery.active').zero?
end


#----------------------------------------------------------------------------------

