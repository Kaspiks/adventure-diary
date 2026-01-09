# frozen_string_literal: true

# Devise configuration for tests
# Note: Devise helpers are included in rails_helper.rb
# This file handles additional route configuration

RSpec.configure do |config|
  config.before(:each, type: :request) do
    Rails.application.reload_routes! unless Rails.application.routes.url_helpers.respond_to?(:new_user_session_path)
  end
end
