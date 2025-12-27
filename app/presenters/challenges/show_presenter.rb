# frozen_string_literal: true

module Challenges
  class ShowPresenter < ApplicationPresenter
    attr_reader :challenge, :current_user

    has_one_decorated :challenge, expose: true

    def initialize(challenge:, current_user:)
      super()
      @challenge = challenge
      @current_user = current_user
    end

    def user_attempt
      @user_attempt ||= current_user.challenge_attempts.for_challenge(challenge).first
    end

    def can_start?
      user_attempt.nil? && challenge.is_active?
    end

    def has_active_attempt?
      user_attempt.present? && !user_attempt.final?
    end
  end
end







