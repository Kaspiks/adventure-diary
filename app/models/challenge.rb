# frozen_string_literal: true

class Challenge < ApplicationRecord
  include DynamicFields::Concerns::HasDynamicFields

  dynamic_fields_config(
    column: :fields_config,
    template_field_class: "ChallengeFields::TemplateField"
  )

  belongs_to :creator_user, class_name: "User"
  belongs_to :location, optional: true
  belongs_to :challenge_type
  belongs_to :difficulty_level
  belongs_to :award_point_level

  has_many :challenge_attempts, dependent: :destroy
  has_many :points_history, dependent: :nullify

  validates :title, presence: true, length: { maximum: 255 }

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :by_creator, ->(user) { where(creator_user: user) }

  searchable_text_column :title

  def owned_by?(user)
    creator_user_id == user.id
  end

  def award_points
    award_point_level.points
  end

  def fields
    template_fields
  end

  def fields=(value)
    self.template_fields = value
  end

  def has_fields?
    has_template_fields?
  end

  def field_count
    template_field_count
  end

  def total_field_points
    template_fields.sum(&:points)
  end

  def available_field_types
    type_code = challenge_type&.code
    ChallengeFields.for_challenge_type(type_code)
  end

  def field_type_options
    ChallengeFields.options_for_select(challenge_type&.code)
  end

  def field_type_defaults(field_type)
    ChallengeFields.defaults_for(challenge_type&.code, field_type)
  end

  def quiz_challenge?
    challenge_type&.code == "quiz"
  end

  def exploration_challenge?
    challenge_type&.code == "exploration"
  end

  def photo_challenge?
    challenge_type&.code == "photo"
  end

  def required_photo_count
    return 1 unless photo_challenge?

    photo_field = template_fields.find { |f| f.type == :photo_upload }
    photo_field&.config&.dig(:max_photos) || 1
  end

  def build_model_field(template_field, storage_data: {})
    template_field.build_model_field(object: self, storage_data: storage_data)
  end

  def build_blank_model_fields
    template_fields.map { |tf| tf.build_blank_model_field(object: self) }
  end

end

# == Schema Information
#
# Table name: challenges
#
#  id                   :bigint           not null, primary key
#  description          :text
#  fields_config        :json             not null
#  is_active            :boolean          default(TRUE), not null
#  title                :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  award_point_level_id :integer          not null
#  challenge_type_id    :integer          not null
#  creator_user_id      :integer          not null
#  difficulty_level_id  :integer          not null
#  location_id          :integer
#
# Indexes
#
#  index_challenges_on_award_point_level_id  (award_point_level_id)
#  index_challenges_on_challenge_type_id     (challenge_type_id)
#  index_challenges_on_creator_user_id       (creator_user_id)
#  index_challenges_on_difficulty_level_id   (difficulty_level_id)
#  index_challenges_on_is_active             (is_active)
#  index_challenges_on_location_id           (location_id)
#  index_challenges_on_title                 (title)
#
# Foreign Keys
#
#  fk_rails_...  (award_point_level_id => award_point_levels.id)
#  fk_rails_...  (challenge_type_id => challenge_types.id)
#  fk_rails_...  (creator_user_id => users.id)
#  fk_rails_...  (difficulty_level_id => difficulty_levels.id)
#  fk_rails_...  (location_id => locations.id)
#
