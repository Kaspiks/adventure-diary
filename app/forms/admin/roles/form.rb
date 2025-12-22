# frozen_string_literal: true

module Admin
  module Roles
    class Form < ApplicationModelForm
      self.object_class_name = "Role"

      delegated_fields :name, :description

      attr_accessor :permission_ids

      def initialize(role)
        super(role)
        @permission_ids = role.permission_ids
      end

      def new_role?
        object.new_record?
      end

      def create(attributes)
        assign_attributes_from(attributes.to_h.symbolize_keys)
        save
      end

      def update(attributes)
        assign_attributes_from(attributes.to_h.symbolize_keys)
        save
      end

      def permissions_grouped
        Permission.grouped_by_resource
      end

      def permission_checked?(permission)
        permission_ids.include?(permission.id)
      end

      private

      def assign_attributes_from(attributes)
        self.name = attributes[:name] if attributes.key?(:name)
        self.description = attributes[:description] if attributes.key?(:description)

        if attributes.key?(:permission_ids)
          ids = attributes[:permission_ids].reject(&:blank?).map(&:to_i)
          object.permissions = Permission.where(id: ids)
          @permission_ids = ids
        end
      end
    end
  end
end



