# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = "noreply@adventure-diary.com"
  require "devise/orm/active_record"

  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.paranoid = true
  config.stretches = Rails.env.test? ? 1 : 12
  config.send_email_changed_notification = true
  config.send_password_change_notification = true
  config.remember_for = 2.weeks
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.timeout_in = 30.minutes
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [:email]
  config.unlock_strategy = :both
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  config.last_attempt_warning = true
  config.reset_password_keys = [:email]
  config.reset_password_within = 6.hours
  config.sign_in_after_reset_password = true
  config.default_scope = :user
  config.sign_out_all_scopes = true
  config.navigational_formats = ["*/*", :html, :turbo_stream]
  config.sign_out_via = :delete
  config.sign_in_after_change_password = true
end

Rails.application.config.to_prepare do
  Devise::SessionsController.layout("unauthenticated")
  Devise::RegistrationsController.layout("unauthenticated")
  Devise::PasswordsController.layout("unauthenticated")
  Devise::ConfirmationsController.layout("unauthenticated")
  Devise::UnlocksController.layout("unauthenticated")
end

Warden::Manager.after_set_user(except: :fetch) do |record, warden, options|
  if record.respond_to?(:session_token) && warden.authenticated?(options[:scope])
    session_token = Devise.friendly_token(20)
    warden.session(options[:scope])["session_token"] = session_token
    record.update_column(:session_token, session_token)
  end
end

Warden::Manager.after_set_user(only: :fetch) do |record, warden, options|
  scope = options[:scope]
  stored_token = warden.session(scope)["session_token"] rescue nil
  if record.respond_to?(:session_token) && warden.authenticated?(scope) && record.session_token.present? && record.session_token != stored_token
    warden.raw_session.clear
    warden.logout(scope)
    throw :warden, scope: scope, message: :session_limited
  end
end
