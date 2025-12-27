# frozen_string_literal: true

module Challenges
  class IndexPresenter < ApplicationPresenter
    attr_reader :challenges, :current_user

    has_many_decorated :challenges, expose: true

    def initialize(challenges:, current_user:)
      super()
      @challenges = challenges
      @current_user = current_user
    end

    def total_count
      challenges.count
    end
  end
end






