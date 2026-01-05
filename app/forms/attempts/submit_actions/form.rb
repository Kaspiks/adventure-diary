# frozen_string_literal: true

module Attempts
  module SubmitActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      attr_accessor :answers, :photos, :photo_captions, :user_latitude, :user_longitude

      def initialize(attempt)
        super(attempt)
      end

      def update(attributes)
        assign_form_attributes(attributes)

        with_safe_transaction do
          unless validate_location_access
            raise ActiveRecord::Rollback
          end

          save_answers
          save_artifacts

          unless object.validate_submission
            object.errors.each { |e| errors.add(e.attribute, e.message) }
            raise ActiveRecord::Rollback
          end

          object.attempt_status = AttemptStatus.submitted
          object.submitted_at = Time.current

          object.save!
        end
      end

      def template_fields
        object.challenge.template_fields
      end

      def model_fields
        @model_fields ||= template_fields.map do |template_field|
          template_field.build_blank_model_field(object: object.challenge)
        end
      end

      private

      def assign_form_attributes(attributes)
        attrs = attributes.to_h.symbolize_keys
        object.assign_attributes(attrs.slice(:evidence_url))
        self.answers = attrs[:answers]
        self.photos = attrs[:photos]
        self.photo_captions = attrs[:photo_captions]
        self.user_latitude = attrs[:user_latitude]
        self.user_longitude = attrs[:user_longitude]
      end

      def validate_location_access
        location = object.challenge.location
        return true unless location&.geofenced?

        # Require user coordinates for geofenced challenges
        if user_latitude.blank? || user_longitude.blank?
          errors.add(:base, "Location verification required. Please enable location access.")
          return false
        end

        user_lat = user_latitude.to_f
        user_lng = user_longitude.to_f

        unless GeoDistance.valid_coordinates?(user_lat, user_lng)
          errors.add(:base, "Invalid location coordinates provided.")
          return false
        end

        unless location.within_radius?(user_lat, user_lng)
          distance = location.distance_from(user_lat, user_lng)
          distance_text = distance >= 1000 ? "#{(distance / 1000).round(1)} km" : "#{distance.round} meters"
          errors.add(:base, "You must be within #{location.radius_meters} meters of #{location.name} to complete this challenge. You are currently #{distance_text} away.")
          return false
        end

        true
      end

      def save_answers
        return unless answers.present?

        answers.each do |field_id, answer_value|
          next if answer_value.blank?

          answer = object.attempt_answers.find_or_initialize_by(field_id: field_id.to_s)

          if answer_value.is_a?(Array)
            answer.answer_value = answer_value.first
            answer.answer_data = { "values" => answer_value }
          else
            answer.answer_value = answer_value.to_s
            answer.answer_data = {}
          end

          template_field = find_template_field(field_id.to_s)
          if template_field
            model_field = build_model_field_with_answer(template_field, answer_value)
            answer.is_correct = model_field.check_answer
          end

          answer.save!
        end
      end

      def find_template_field(field_id)
        template_fields.find { |f| f.id == field_id }
      end

      def build_model_field_with_answer(template_field, answer_value)
        model_field = template_field.build_blank_model_field(object: object.challenge)

        case template_field.type
        when :multiple_choice
          model_field.selected_answers = Array(answer_value)
        else
          model_field.answer = answer_value.to_s
        end

        model_field
      end

      def save_artifacts
        return unless photos.present?

        photos.each do |field_id, photo_files|
          field_captions = photo_captions&.dig(field_id.to_s) || {}

          Array(photo_files).each_with_index do |photo_file, index|
            next unless photo_file.present?

            caption = field_captions[(index + 1).to_s]

            artifact = object.attempt_artifacts.build(
              kind: "photo",
              field_id: field_id.to_s,
              metadata: caption.present? ? { caption: caption } : {}
            )
            artifact.file.attach(photo_file)
            artifact.save!
          end
        end
      end
    end
  end
end
