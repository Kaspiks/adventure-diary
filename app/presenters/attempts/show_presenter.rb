# frozen_string_literal: true

module Attempts
  class ShowPresenter < ApplicationPresenter
    attr_reader :attempt, :current_user

    has_one_decorated :attempt, expose: true

    def initialize(attempt:, current_user:)
      super()
      @attempt = attempt
      @current_user = current_user
    end

    def can_submit?
      attempt.owned_by?(current_user) && attempt.can_submit?
    end

    def can_review?
      return false if attempt.owned_by?(current_user)
      return false unless attempt.can_review?
      return true if current_user.administrator?

      current_user.company_user? && attempt.challenge.owned_by?(current_user)
    end
  end
end
