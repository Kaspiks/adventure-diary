# frozen_string_literal: true

module Admin
  module Rewards
    class Form < ApplicationModelForm
      self.object_class_name = "Reward"

      delegated_fields :title, :description, :cost_points, :is_active, :stock_quantity, :image

      def initialize(reward)
        super(reward)
      end

      def has_image?
        object.image.attached?
      end
    end
  end
end

