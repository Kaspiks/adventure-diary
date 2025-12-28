# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    sequence(:title) { |n| "Challenge #{n}" }
    description { "Test challenge description" }
    is_active { true }
    fields_config { [] }

    association :creator_user, factory: [:user, :company_user]
    association :challenge_type, factory: [:challenge_type, :quiz]
    association :difficulty_level, factory: [:difficulty_level, :easy]
    association :award_point_level, factory: [:award_point_level, :bronze]
    location { nil }

    trait :inactive do
      is_active { false }
    end

    trait :with_text_field do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "text_input",
            "label" => "What is the answer?",
            "required" => true,
            "points" => 10,
            "correct_answer" => "correct"
          }
        ]
      end
    end

    trait :with_mixed_fields do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "text_input",
            "label" => "Text question",
            "required" => true,
            "points" => 10,
            "correct_answer" => "answer"
          },
          {
            "id" => SecureRandom.uuid,
            "type" => "single_choice",
            "label" => "Choice question",
            "required" => true,
            "points" => 10,
            "options" => %w[A B C D],
            "correct_answer" => "B"
          }
        ]
      end
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
