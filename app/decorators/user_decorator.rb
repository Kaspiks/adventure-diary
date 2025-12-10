# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate :full_name, :initials, :email, :first_name, :last_name,
           :admin?, :blocked?, :active?, :created_at, :updated_at,
           :last_sign_in_at, :sign_in_count, :current_sign_in_at,
           :current_sign_in_ip, :last_sign_in_ip, to: :object
end
