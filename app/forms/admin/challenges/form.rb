# frozen_string_literal: true

module Admin
  module Challenges
    class Form < ApplicationModelForm
      self.object_class_name = "Challenge"

      delegated_fields :title, :description, :location_id, :challenge_type_id,
                       :difficulty_level_id, :award_point_level_id, :is_active, :fields_config

      def initialize(challenge)
        super(challenge)
      end

      def locations
        Location.ordered
      end

      def challenge_types
        ChallengeType.ordered
      end

      def difficulty_levels
        DifficultyLevel.ordered
      end

      def award_point_levels
        AwardPointLevel.ordered
      end

      def fields
        object.fields
      end

      def challenge_type_code
        object.challenge_type&.code
      end

      def available_field_types
        object.available_field_types
      end
    end
  end
end
