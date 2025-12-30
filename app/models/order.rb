# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  belongs_to :reward
  belongs_to :order_status

  has_one :points_history_entry, class_name: "PointsHistory", dependent: :nullify

  validates :total_points, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_reward, ->(reward) { where(reward: reward) }
  scope :for_reward_owner, ->(owner) { joins(:reward).where(rewards: { owner_user_id: owner.id }) }
  scope :pending, -> { joins(:order_status).where(order_statuses: { code: "pending" }) }
  scope :non_cancelled, -> { joins(:order_status).where.not(order_statuses: { code: "cancelled" }) }

  delegate :pending?, :approved?, :delivered?, :cancelled?, :final?, to: :order_status

  def owned_by?(user)
    return false unless user

    user_id == user.id
  end

  def reward_owned_by?(user)
    return false unless user

    reward.owned_by?(user)
  end

  def can_transition_to?(new_status_code)
    return false if final?

    case order_status.code
    when "pending"
      %w[approved cancelled].include?(new_status_code.to_s)
    when "approved"
      %w[delivered cancelled].include?(new_status_code.to_s)
    else
      false
    end
  end

  def transition_to!(new_status_code)
    new_status = OrderStatus.find_by!(code: new_status_code)
    raise "Invalid transition from #{order_status.code} to #{new_status_code}" unless can_transition_to?(new_status_code)

    update!(order_status: new_status)
  end
end

# == Schema Information
#
# Table name: orders
#
#  id              :bigint           not null, primary key
#  total_points    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_status_id :bigint           not null
#  reward_id       :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_orders_on_order_status_id                (order_status_id)
#  index_orders_on_reward_id                      (reward_id)
#  index_orders_on_reward_id_and_order_status_id  (reward_id,order_status_id)
#  index_orders_on_user_id                        (user_id)
#  index_orders_on_user_id_and_created_at         (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (order_status_id => order_statuses.id)
#  fk_rails_...  (reward_id => rewards.id)
#  fk_rails_...  (user_id => users.id)
#

