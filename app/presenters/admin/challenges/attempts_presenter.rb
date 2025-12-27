# frozen_string_literal: true

module Admin
  module Challenges
    class AttemptsPresenter < ApplicationPresenter
      attr_reader :challenge, :attempts

      has_one_decorated :challenge, expose: true
      has_many_decorated :attempts, expose: true

      def initialize(challenge:, attempts:)
        super()
        @challenge = challenge
        @attempts = attempts
      end

      def total_count
        attempts.count
      end
    end
  end
end






