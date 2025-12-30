# frozen_string_literal: true

class RewardDecorator < ApplicationDecorator
  delegate :title, :description, :cost_points, :is_active, :stock_quantity,
           :owner_user, :created_at, :updated_at, :orders, :image, to: :object

  def status_badge
    is_active ? "Active" : "Inactive"
  end

  def status_color
    is_active ? "emerald" : "slate"
  end

  def stock_display
    return "Unlimited" unless object.has_stock_limit?
    return "Out of Stock" if object.out_of_stock?

    "#{stock_quantity} left"
  end

  def stock_color
    return "slate" unless object.has_stock_limit?
    return "red" if object.out_of_stock?
    return "amber" if stock_quantity < 5

    "emerald"
  end

  def cost_display
    "#{cost_points} pts"
  end

  def owner_name
    owner_user&.full_name
  end

  def orders_count
    orders.count
  end

  def pending_orders_count
    orders.pending.count
  end

  def truncated_description(length: 100)
    return "" unless description.present?

    ActionController::Base.helpers.strip_tags(description).truncate(length)
  end

  def has_image?
    object.image.attached?
  end

  def description_html
    description&.html_safe
  end
end

