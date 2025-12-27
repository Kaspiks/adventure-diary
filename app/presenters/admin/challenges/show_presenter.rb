# frozen_string_literal: true

module Admin
  module Challenges
    class ShowPresenter < ApplicationPresenter
      attr_reader :challenge

      has_one_decorated :challenge, expose: true

      def initialize(challenge:)
        super()
        @challenge = challenge
      end

      def attempts_count
        challenge.challenge_attempts.count
      end

      def pending_attempts_count
        challenge.challenge_attempts.pending_review.count
      end
    end
  end
end






