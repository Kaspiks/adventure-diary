# frozen_string_literal: true

module Admin
  module Rewards
    class Form < ApplicationModelForm
      self.object_class_name = "Reward"

      delegated_fields :title, :description, :cost_points, :is_active, :stock_quantity, :image

      validate :validate_image

      def initialize(reward)
        super(reward)
      end

      def has_image?
        object.image.attached?
      end

      private

      def validate_image
        return unless object.image.attached?

        acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
        unless acceptable_types.include?(object.image.content_type)
          errors.add(:image, :invalid_image_type)
        end

        if object.image.byte_size > 10.megabytes
          errors.add(:image, :image_too_large)
        end
      end
    end
  end
end

