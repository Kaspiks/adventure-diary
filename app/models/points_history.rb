# frozen_string_literal: true

class PointsHistory < ApplicationRecord
  self.table_name = "points_history"

  REASON_CHALLENGE_AWARD = "challenge_award"
  REASON_REWARD_PURCHASE = "reward_purchase"
  REASON_REWARD_REDEMPTION = "reward_redemption"

  belongs_to :user
  belongs_to :challenge, optional: true
  belongs_to :order, optional: true

  validates :delta_points, presence: true, numericality: { only_integer: true }
  validates :reason_code, presence: true, length: { maximum: 50 }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_challenge, ->(challenge) { where(challenge: challenge) }
  scope :for_order, ->(order) { where(order: order) }
end

# == Schema Information
#
# Table name: points_history
#
#  id           :bigint           not null, primary key
#  delta_points :integer          not null
#  reason_code  :string(50)       not null
#  created_at   :datetime         not null
#  challenge_id :integer
#  order_id     :integer
#  user_id      :integer          not null
#
# Indexes
#
#  index_points_history_on_challenge_id  (challenge_id)
#  index_points_history_on_created_at    (created_at)
#  index_points_history_on_order_id      (order_id)
#  index_points_history_on_reason_code   (reason_code)
#  index_points_history_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (challenge_id => challenges.id)
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (user_id => users.id)
#
