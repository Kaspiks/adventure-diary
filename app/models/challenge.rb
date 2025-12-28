# frozen_string_literal: true

class Challenge < ApplicationRecord
  belongs_to :creator_user, class_name: "User"
  belongs_to :location, optional: true
  belongs_to :challenge_type
  belongs_to :difficulty_level
  belongs_to :award_point_level

  has_many :challenge_attempts, dependent: :destroy
  has_many :points_history, dependent: :nullify

  validates :title, presence: true, length: { maximum: 255 }
  validate :validate_fields_config

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
    (fields_config || []).map { |f| ChallengeField.new(f.symbolize_keys) }
  end

  def fields=(value)
    self.fields_config = value.is_a?(Array) ? value : []
  end

  def has_fields?
    fields_config.present? && fields_config.any?
  end

  def field_count
    fields_config&.size || 0
  end

  def total_field_points
    fields.sum(&:points)
  end

  def available_field_types
    type_code = challenge_type&.code
    ChallengeFields.for_challenge_type(type_code)
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

    photo_field = fields.find { |f| f.photo_upload? }
    photo_field&.max_photos || 1
  end

  private

  def validate_fields_config
    return if fields_config.blank?

    fields_config.each_with_index do |field, index|
      unless field["type"].present? && ChallengeFields.valid_type?(field["type"])
        errors.add(:fields_config, "field #{index + 1} has invalid type")
      end
      unless field["label"].present?
        errors.add(:fields_config, "field #{index + 1} must have a label")
      end
    end
  end
end

class ChallengeField
  attr_accessor :id, :type, :label, :instructions, :required, :points,
                :options, :correct_answer, :correct_answers,
                :image_url, :display_text, :max_photos, :number_of_blanks,
                :case_sensitive, :hint, :require_caption

  def initialize(attrs = {})
    @id = attrs[:id] || SecureRandom.uuid
    @type = attrs[:type]&.to_s
    @label = attrs[:label]
    @instructions = attrs[:instructions]
    @required = attrs.fetch(:required, true)
    @points = attrs[:points].to_i
    @options = attrs[:options] || []
    @correct_answer = attrs[:correct_answer]
    @correct_answers = attrs[:correct_answers] || []
    @image_url = attrs[:image_url]
    @display_text = attrs[:display_text]
    @max_photos = attrs[:max_photos] || 1
    @number_of_blanks = attrs[:number_of_blanks] || 1
    @case_sensitive = attrs.fetch(:case_sensitive, false)
    @hint = attrs[:hint]
    @require_caption = attrs.fetch(:require_caption, false)
  end

  def to_h
    {
      id: id,
      type: type,
      label: label,
      instructions: instructions,
      required: required,
      points: points,
      options: options,
      correct_answer: correct_answer,
      correct_answers: correct_answers,
      image_url: image_url,
      display_text: display_text,
      max_photos: max_photos,
      number_of_blanks: number_of_blanks,
      case_sensitive: case_sensitive,
      hint: hint,
      require_caption: require_caption
    }.compact
  end

  def text_input?
    type == "text_input"
  end

  def single_choice?
    type == "single_choice"
  end

  def multiple_choice?
    type == "multiple_choice"
  end

  def photo_upload?
    type == "photo_upload"
  end

  def hidden_letter?
    type == "hidden_letter"
  end

  def check_answer(response)
    return true if !required && response.blank?

    case type
    when "text_input"
      return false unless correct_answer.present?
      response.to_s.strip.downcase == correct_answer.strip.downcase
    when "hidden_letter"
      return false unless correct_answer.present?
      if case_sensitive
        response.to_s.strip == correct_answer.strip
      else
        response.to_s.strip.downcase == correct_answer.strip.downcase
      end
    when "single_choice"
      correct_answer.present? && response.to_s == correct_answer
    when "multiple_choice"
      return false if response.blank?

      given = Array(response).map(&:to_s).sort
      expected = correct_answers.map(&:to_s).sort
      given == expected
    when "photo_upload"
      response.present?
    else
      true
    end
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
