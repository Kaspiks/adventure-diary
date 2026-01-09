# frozen_string_literal: true

module Admin
  module Challenges
    class Form < ApplicationModelForm
      # Note: We don't include HasDynamicForm here because this form is for
      # CONFIGURING template fields, not for users filling in answers.

      self.object_class_name = "Challenge"

      delegated_fields :title, :description, :location_id, :challenge_type_id,
                       :difficulty_level_id, :award_point_level_id, :is_active

      validate :validate_template_fields

      def initialize(challenge)
        super(challenge)
      end

      # Update with params handling for both model attributes and template fields
      def update(attributes)
        # Ensure we have a proper hash with symbol keys
        attrs = attributes.respond_to?(:to_unsafe_h) ? attributes.to_unsafe_h : attributes.to_h
        attrs = attrs.deep_symbolize_keys

        # Handle template fields from the form
        # The controller already parses fields_config into an array of hashes
        if attrs.key?(:fields_config)
          fields_data = attrs[:fields_config] || []
          # Ensure each field is a proper hash with symbol keys
          fields_data = fields_data.map do |field|
            field.respond_to?(:to_unsafe_h) ? field.to_unsafe_h.deep_symbolize_keys : field.deep_symbolize_keys
          end
          object.template_fields = fields_data
          attrs = attrs.except(:fields_config)
        end

        object.assign_attributes(attrs)
        save
      end

      alias create update

      # Collections for dropdowns
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

      # Template fields from the challenge
      def template_fields
        object.template_fields
      end

      # Alias for backwards compatibility
      def fields
        template_fields
      end

      def challenge_type_code
        object.challenge_type&.code
      end

      def available_field_types
        object.available_field_types
      end

      # Options for field type dropdown
      def field_type_options
        object.field_type_options
      end

      # Get defaults for all available field types (for JS)
      def field_type_defaults_json
        available_field_types.keys.each_with_object({}) do |field_type, hash|
          hash[field_type.to_s] = ChallengeFields.defaults_for(challenge_type_code, field_type)
        end.to_json
      end

      private

      def validate_template_fields
        template_fields.each_with_index do |field, index|
          unless field.valid_type?
            errors.add(:fields_config, :invalid_field_type, index: index + 1, type: field.type)
          end
          if field.label.blank?
            errors.add(:fields_config, :field_label_required, index: index + 1)
          end
        end
      end
    end
  end
end
