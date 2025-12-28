# frozen_string_literal: true

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.before(:each, type: :request) do
    Rails.application.reload_routes! unless Rails.application.routes.url_helpers.respond_to?(:new_user_session_path)
  end
end
