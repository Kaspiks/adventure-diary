# frozen_string_literal: true

class OrderDecorator < ApplicationDecorator
  delegate :user, :reward, :order_status, :total_points, :created_at, :updated_at, to: :object

  def status_name
    order_status&.name
  end

  def status_code
    order_status&.code
  end

  def status_color
    case order_status&.code
    when "pending"
      "amber"
    when "approved"
      "blue"
    when "delivered"
      "emerald"
    when "cancelled"
      "red"
    else
      "slate"
    end
  end

  def points_display
    "#{total_points} pts"
  end

  def buyer_name
    user&.full_name
  end

  def buyer_email
    user&.email
  end

  def reward_title
    reward&.title
  end

  def reward_owner_name
    reward&.owner_user&.full_name
  end

  def ordered_at
    created_at.strftime("%b %d, %Y %H:%M")
  end

  def can_approve?
    object.can_transition_to?("approved")
  end

  def can_deliver?
    object.can_transition_to?("delivered")
  end

  def can_cancel?
    object.can_transition_to?("cancelled")
  end
end

