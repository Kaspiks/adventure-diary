# frozen_string_literal: true

class Reward < ApplicationRecord
  belongs_to :owner_user, class_name: "User"

  has_many :orders, dependent: :restrict_with_error
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 255 }
  validates :cost_points, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :by_owner, ->(user) { where(owner_user: user) }
  scope :in_stock, -> { where("stock_quantity IS NULL OR stock_quantity > 0") }
  scope :available, -> { active.in_stock }

  searchable_text_column :title

  def owned_by?(user)
    return false unless user

    owner_user_id == user.id
  end

  def in_stock?
    stock_quantity.nil? || stock_quantity.positive?
  end

  def out_of_stock?
    stock_quantity.present? && stock_quantity <= 0
  end

  def has_stock_limit?
    stock_quantity.present?
  end

  def decrement_stock!
    return unless has_stock_limit?

    with_lock do
      raise "Out of stock" if out_of_stock?

      decrement!(:stock_quantity)
    end
  end

  sortable_by \
    columns: [:title, :cost_points, :stock_quantity],
    scopes: {
      orders_count: ->(direction) {
        left_joins(:orders)
          .group(:id)
          .order(Arel.sql("COUNT(orders.id) #{direction}"))
      }
    },
    defaults: { column: :stock_quantity, direction: :desc }
end

# == Schema Information
#
# Table name: rewards
#
#  id             :bigint           not null, primary key
#  cost_points    :integer          not null
#  description    :text
#  is_active      :boolean          default(TRUE), not null
#  stock_quantity :integer
#  title          :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_user_id  :bigint           not null
#
# Indexes
#
#  index_rewards_on_cost_points    (cost_points)
#  index_rewards_on_is_active      (is_active)
#  index_rewards_on_owner_user_id  (owner_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_user_id => users.id)
#

