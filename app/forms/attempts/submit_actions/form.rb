# frozen_string_literal: true

module Attempts
  module SubmitActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      attr_accessor :answers, :photos

      def initialize(attempt)
        super(attempt)
      end

      def update(attributes)
        assign_form_attributes(attributes)

        with_safe_transaction do
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

      private

      def assign_form_attributes(attributes)
        attrs = attributes.to_h.symbolize_keys
        object.assign_attributes(attrs.slice(:evidence_url))
        self.answers = attrs[:answers]
        self.photos = attrs[:photos]
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

          field = object.challenge.fields.find { |f| f.id == field_id.to_s }
          answer.is_correct = field.check_answer(answer_value) if field

          answer.save!
        end
      end

      def save_artifacts
        return unless photos.present?

        photos.each do |field_id, photo_files|
          Array(photo_files).each do |photo_file|
            next unless photo_file.present?

            artifact = object.attempt_artifacts.build(
              kind: "photo",
              field_id: field_id.to_s
            )
            artifact.file.attach(photo_file)
            artifact.save!
          end
        end
      end
    end
  end
end
