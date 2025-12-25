# frozen_string_literal: true

module Admin
  module Attempts
    class IndexPresenter < ApplicationPresenter
      attr_reader :attempts

      has_many_decorated :attempts, expose: true

      def initialize(attempts:)
        super()
        @attempts = attempts
      end

      def total_count
        attempts.count
      end
    end
  end
end



