# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, dependent: :nullify
  has_and_belongs_to_many :permissions

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }

  scope :ordered, -> { order(:name) }

  def has_permission?(permission_code)
    permissions.exists?(code: permission_code)
  end
end

# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  description :text
#  name        :string(100)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#







