require 'simplecov'
# ^^ https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config

require 'cucumber/rails'
require 'cucumber/timecop'
require 'cucumber/rspec/doubles'
require 'capybara/poltergeist'
require 'email_spec/cucumber'
require 'webdrivers/chromedriver'

# Put the Geocoder into test mode so no actual API calls are made and stub with fake data
require_relative '../../spec/support/geocoder'


Webdrivers.install_dir = Rails.root.join('features', 'support', 'webdrivers')
# -------------------------
# Configure WebMock and VCR. Have to have them always configured (for all scenarios)
# in case Webdrivers needs to update the driver, which will force a request.
#
# Do not use VCR or WebMock on sites that Webdrivers gem uses to download and update drivers:
VCR.configure do |c|
  c.ignore_hosts('chromedriver.storage.googleapis.com')
end

webdrivers_download_sites = [
    "chromedriver.storage.googleapis.com",
    "github.com/mozilla/geckodriver/releases",
    "selenium-release.storage.googleapis.com",
    "developer.microsoft.com/en-us/microsoft-edge/tools/webdriver"
]
WebMock.disable_net_connect!(allow_localhost: true, allow: webdrivers_download_sites)

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir     = 'features/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.default_cassette_options = { allow_playback_repeats: true }

  webdrivers_download_sites.each do | webdriver_download_site |
    c.ignore_hosts(webdriver_download_site)
  end
end
# -------------------------


ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Cucumber::Rails::Database.javascript_strategy = :truncation


Before do
 # I18n.locale = 'en'
 ENV['SHF_BETA'] = 'no'
 WebMock.disable_net_connect!(allow_localhost: true)
end


Warden.test_mode!
World Warden::Test::Helpers
After { Warden.test_reset! }

def path_with_locale(visit_path)
  "/#{I18n.locale}#{visit_path}"
end

def i18n_content(content, locale=I18n.locale)
  I18n.t(content, locale)
end

Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Displayed chrome browser - @selenium_browser
Capybara.register_driver :selenium_browser do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome
  )
end


# Uncomment this to show the 20 slowest scenarios
=begin
scenario_times = {}

Around() do |scenario, block|
  start = Time.now
  block.call
  scenario_times["#{scenario.feature.file}::#{scenario.name}"] = Time.now - start
end

at_exit do
  max_scenarios = scenario_times.size > 20 ? 20 : scenario_times.size
  puts "------------- Top #{max_scenarios} slowest scenarios -------------"
  sorted_times = scenario_times.sort { |a, b| b[1] <=> a[1] }
  sorted_times[0..max_scenarios - 1].each do |key, value|
    puts "#{value.round(2)}  #{key}"
  end
end
=end
