# frozen_string_literal: true

module Attempts
  class EditForm < ApplicationModelForm
    self.object_class_name = "ChallengeAttempt"

    def initialize(attempt)
      super(attempt)
    end

    def update(attributes)
      attrs = attributes.to_h.deep_symbolize_keys

      # Update answers
      if attrs[:answers].present?
        update_answers(attrs[:answers])
      end

      # Handle new photo uploads
      if attrs[:photos].present?
        upload_photos(attrs[:photos])
      end

      # Validate and save
      return false unless validate_submission

      object.save
    end

    def template_fields
      object.challenge.template_fields
    end

    private

    def update_answers(answers_params)
      answers_params.each do |field_id, answer_value|
        template_field = object.find_template_field(field_id)
        next unless template_field

        existing_answer = object.answer_for_field(field_id)

        if existing_answer
          # Update existing answer
          update_existing_answer(existing_answer, template_field, answer_value)
        else
          # Create new answer
          create_answer(template_field, answer_value)
        end
      end
    end

    def update_existing_answer(answer, template_field, value)
      case template_field.type
      when :multiple_choice
        answer.answer_value = value.is_a?(Array) ? value.compact_blank.join(",") : value.to_s
      else
        answer.answer_value = value.to_s
      end

      # Re-check correctness
      model_field = object.build_model_field_with_answer(template_field)
      answer.is_correct = model_field.check_answer
      answer.save
    end

    def create_answer(template_field, value)
      answer_value = case template_field.type
                     when :multiple_choice
                       value.is_a?(Array) ? value.compact_blank.join(",") : value.to_s
                     else
                       value.to_s
                     end

      model_field = template_field.build_blank_model_field(object: object.challenge)
      case template_field.type
      when :multiple_choice
        model_field.selected_answers = value.is_a?(Array) ? value.compact_blank : [value].compact_blank
      else
        model_field.answer = answer_value
      end

      object.attempt_answers.create!(
        field_id: template_field.id,
        answer_value: answer_value,
        is_correct: model_field.check_answer
      )
    end

    def upload_photos(photos_params)
      photos_params.each do |field_id, files|
        next if files.blank?

        files = [files] unless files.is_a?(Array)
        files.each do |file|
          next unless file.respond_to?(:original_filename)

          artifact = object.attempt_artifacts.build(kind: "photo", field_id: field_id.to_s)
          artifact.file.attach(file)
          artifact.save!
        end
      end
    end

    def validate_submission
      if template_fields.empty?
        if object.photos.empty?
          errors.add(:base, :photo_required)
        end
        return errors.empty?
      end

      template_fields.each do |template_field|
        next unless template_field.required?

        case template_field.type
        when :photo_upload
          photos_count = object.photos_for_field(template_field.id).count
          if photos_count < 1
            errors.add(:base, :photo_required_for_field, field_label: template_field.label)
          end
        when :text_input, :single_choice, :hidden_letter
          answer = object.answer_for_field(template_field.id)
          if answer.blank? || answer.answer_value.blank?
            errors.add(:base, :field_required, field_label: template_field.label)
          end
        when :multiple_choice
          answer = object.answer_for_field(template_field.id)
          if answer.blank? || answer.answer_value_array.empty?
            errors.add(:base, :field_required, field_label: template_field.label)
          end
        end
      end

      errors.empty?
    end
  end
end
