# frozen_string_literal: true

class Setting < ApplicationRecord
  enum :value_type, {
    string: "string",
    integer: "integer",
    boolean: "boolean",
    text: "text",
    rich_text: "rich_text"
  }, prefix: true

  enum :group, {
    general: "general",
    appearance: "appearance",
    content: "content",
    notifications: "notifications"
  }, prefix: true

  validates :key, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :value_type, presence: true
  validates :group, presence: true

  scope :ordered, -> { order(:group, :key) }
  scope :by_group, ->(group) { where(group: group) }

  def self.[](key)
    find_by(key: key)&.typed_value
  end

  def self.[]=(key, value)
    find_by(key: key)&.update(value: value.to_s)
  end

  def self.grouped
    ordered.group_by(&:group)
  end

  def typed_value
    case value_type
    when "integer" then value.to_i
    when "boolean" then ActiveModel::Type::Boolean.new.cast(value)
    else value
    end
  end

  def boolean?
    value_type_boolean?
  end

  def rich_text?
    value_type_rich_text?
  end

  def multiline?
    value_type_text? || value_type_rich_text?
  end
end

# == Schema Information
#
# Table name: settings
#
#  id          :bigint           not null, primary key
#  description :string(500)
#  group       :string(50)       default("general"), not null
#  key         :string(100)      not null
#  value       :text
#  value_type  :string(50)       default("string"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_settings_on_group  (group)
#  index_settings_on_key    (key) UNIQUE
#
