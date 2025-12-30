# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable, :lockable, :timeoutable

  belongs_to :role, optional: true

  has_many :created_challenges, class_name: "Challenge", foreign_key: :creator_user_id, dependent: :restrict_with_error, inverse_of: :creator_user
  has_many :challenge_attempts, dependent: :destroy
  has_many :reviewed_attempts, class_name: "ChallengeAttempt", foreign_key: :reviewer_user_id, dependent: :nullify, inverse_of: :reviewer_user
  has_many :points_history, dependent: :destroy
  has_many :owned_rewards, class_name: "Reward", foreign_key: :owner_user_id, dependent: :restrict_with_error, inverse_of: :owner_user
  has_many :orders, dependent: :restrict_with_error

  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where(blocked: false) }
  scope :blocked, -> { where(blocked: true) }
  scope :admins, -> { where(admin: true) }
  scope :with_role, ->(role_name) { joins(:role).where(roles: { name: role_name }) }

  searchable_text_column :first_name
  searchable_text_column :last_name
  searchable_text_column :email

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def active?
    !blocked?
  end

  def active_for_authentication?
    super && !blocked?
  end

  def inactive_message
    blocked? ? :blocked : super
  end

  def has_permission?(permission_code)
    return true if admin?
    return false unless role

    role.has_permission?(permission_code)
  end

  def role_name
    role&.name || "No Role"
  end

  def administrator?
    admin? || role&.name == "administrator"
  end

  def company_user?
    role&.name == "company_user"
  end

  def general_user?
    role&.name == "general_user"
  end

  def can_create_challenges?
    administrator? || company_user?
  end

  def can_review_attempts?
    administrator? || company_user?
  end

  def add_points!(points, reason_code:, challenge: nil, order: nil)
    transaction do
      increment!(:reward_points, points)
      points_history.create!(
        delta_points: points,
        reason_code: reason_code,
        challenge: challenge,
        order: order
      )
    end
  end

  def deduct_points!(points, reason_code:, order: nil)
    transaction do
      lock!
      raise "Insufficient points" if reward_points < points

      decrement!(:reward_points, points)
      points_history.create!(
        delta_points: -points,
        reason_code: reason_code,
        order: order
      )
    end
  end

  def can_afford?(cost)
    reward_points >= cost
  end

  def can_create_rewards?
    administrator? || company_user?
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  blocked                :boolean          default(FALSE), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(45)
#  email                  :string(255)      not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(45)
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  reward_points          :integer          default(0), not null
#  session_token          :string(20)
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role_id                :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#
