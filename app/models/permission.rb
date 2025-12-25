# frozen_string_literal: true

class Permission < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :code, presence: true, uniqueness: true, length: { maximum: 100 }

  scope :ordered, -> { order(:code) }

  def self.grouped_by_resource
    all.ordered.group_by { |p| p.code.split(".").first }
  end
end

# == Schema Information
#
# Table name: permissions
#
#  id          :integer          not null, primary key
#  code        :string(100)      not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_permissions_on_code  (code) UNIQUE
#







