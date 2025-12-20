# frozen_string_literal: true

module Admin
  module Roles
    class IndexPresenter < ApplicationPresenter
      attr_reader :roles

      has_many_decorated :roles, expose: true

      def initialize(roles:)
        super()
        @roles = roles
      end

      def total_count
        roles.count
      end
    end
  end
end


