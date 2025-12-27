# frozen_string_literal: true

module Admin
  module Attempts
    class ShowPresenter < ApplicationPresenter
      attr_reader :attempt

      has_one_decorated :attempt, expose: true

      def initialize(attempt:)
        super()
        @attempt = attempt
      end
    end
  end
end






