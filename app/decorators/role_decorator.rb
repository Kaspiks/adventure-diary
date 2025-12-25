# frozen_string_literal: true

class RoleDecorator < ApplicationDecorator
  delegate :name, :description, :permissions, :users, :created_at, :updated_at, to: :object

  def permissions_count
    permissions.count
  end

  def users_count
    users.count
  end

  def permission_codes
    permissions.pluck(:code).sort
  end
end





