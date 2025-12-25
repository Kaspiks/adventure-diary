# frozen_string_literal: true

module Admin
  module Roles
    class ShowPresenter < ApplicationPresenter
      attr_reader :role

      has_one_decorated :role, expose: true

      def initialize(role:)
        super()
        @role = role
      end

      def permissions_grouped
        role.permissions.ordered.group_by { |p| p.code.split(".").first }
      end

      def users_count
        role.users.count
      end

      def can_delete?
        !role.users.exists?
      end
    end
  end
end








