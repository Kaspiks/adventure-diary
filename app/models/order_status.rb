# frozen_string_literal: true

class OrderStatus < ApplicationRecord
  has_many :orders, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }

  scope :ordered, -> { order(:name) }
  scope :final, -> { where(is_final: true) }

  class << self
    def find_by_code(code)
      find_by(code: code)
    end

    def method_missing(method_name, *args, &block)
      status = find_by(code: method_name.to_s)
      return status if status

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      exists?(code: method_name.to_s) || super
    end

    def codes
      @codes ||= pluck(:code)
    end

    def reset_codes_cache!
      @codes = nil
    end
  end

  def status?(status_code)
    code == status_code.to_s
  end

  def final?
    is_final
  end

  # Dynamic instance methods for status checking
  # Returns true if this status matches the queried code, false otherwise
  def method_missing(method_name, *args, &block)
    method_str = method_name.to_s
    if method_str.end_with?("?")
      code == method_str.chomp("?")
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_str = method_name.to_s
    method_str.end_with?("?") || super
  end
end

# == Schema Information
#
# Table name: order_statuses
#
#  id         :bigint           not null, primary key
#  code       :string(50)       not null
#  is_final   :boolean          default(FALSE), not null
#  name       :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_order_statuses_on_code  (code) UNIQUE
#

