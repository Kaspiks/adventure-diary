# frozen_string_literal: true

module DynamicFields
  module FieldExtensions
    extend ActiveSupport::Concern

    included do
      class_attribute :field_extension_blocks, default: []
    end

    class_methods do
      def field_extensions(&block)
        self.field_extension_blocks = field_extension_blocks + [block]
      end
    end

    def apply_extensions_to(field_class)
      return if field_extension_blocks.empty?

      type_instance = self

      field_extension_blocks.each do |extension_block|
        field_class.class_eval do
          instance_exec(type_instance, &extension_block)
        end
      end
    end
  end
end
