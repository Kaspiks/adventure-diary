# frozen_string_literal: true

module Admin
  module Settings
    class Form < ApplicationModelForm
      self.object_class_name = "Setting"

      attr_accessor :value

      delegate :key, :value_type, :group, :description, :rich_text?, :boolean?, :multiline?, to: :object

      def initialize(setting)
        super(setting)
        @value = setting.value
      end

      def update(attributes)
        assign_attributes_from(attributes.to_h.symbolize_keys)
        save
      end

      def decorated_setting
        @decorated_setting ||= SettingDecorator.new(object)
      end

      private

      def assign_attributes_from(attributes)
        self.value = attributes[:value] if attributes.key?(:value)
        object.value = value
      end
    end
  end
end
