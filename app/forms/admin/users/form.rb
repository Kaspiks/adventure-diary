# frozen_string_literal: true

module Admin
  module Users
    class Form < ApplicationModelForm
      self.object_class_name = "User"

      delegated_fields :first_name, :last_name, :email, :admin, :blocked, :role_id

      string_field :password
      string_field :password_confirmation

      def initialize(user)
        super(user)
      end

      def new_user?
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

      def available_roles
        Role.ordered
      end

      private

      def assign_attributes_from(attributes)
        self.first_name = attributes[:first_name] if attributes.key?(:first_name)
        self.last_name = attributes[:last_name] if attributes.key?(:last_name)
        self.email = attributes[:email] if attributes.key?(:email)
        self.admin = attributes[:admin] if attributes.key?(:admin)
        self.blocked = attributes[:blocked] if attributes.key?(:blocked)
        self.role_id = attributes[:role_id] if attributes.key?(:role_id)

        if attributes[:password].present?
          object.password = attributes[:password]
          object.password_confirmation = attributes[:password_confirmation]
        end
      end
    end
  end
end
