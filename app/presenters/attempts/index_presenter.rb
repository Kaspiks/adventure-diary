# frozen_string_literal: true

module Attempts
  class IndexPresenter < ApplicationPresenter
    attr_reader :attempts, :current_user

    has_many_decorated :attempts, expose: true

    def initialize(attempts:, current_user:)
      super()
      @attempts = attempts
      @current_user = current_user
    end

    def total_count
      attempts.count
    end
  end
end






