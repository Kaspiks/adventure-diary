# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  config.include FactoryBot::Syntax::Methods

  config.before(:each, type: :system) do
    skip "System specs require Chrome browser" unless system_specs_enabled?
  end
end

def system_specs_enabled?
  return false if ENV['SKIP_SYSTEM_SPECS'] == 'true'
  return false if ENV['CI'] && !ENV['CHROME_AVAILABLE']
  
  if File.exist?('/.dockerenv') && !chrome_available?
    return false
  end
  
  true
end

def chrome_available?
  system('which chromium-browser > /dev/null 2>&1') ||
    system('which google-chrome > /dev/null 2>&1') ||
    system('which chromium > /dev/null 2>&1')
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

require 'capybara/rails'
require 'capybara/rspec'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,1400')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5
