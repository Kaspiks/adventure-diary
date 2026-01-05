# frozen_string_literal: true

module Attempts
  class EditPresenter < ApplicationPresenter
    attr_reader :attempt, :current_user

    has_one_decorated :attempt, expose: true

    def initialize(attempt:, current_user:)
      super()
      @attempt = attempt
      @current_user = current_user
    end

    def challenge
      attempt.challenge
    end

    def template_fields
      challenge.template_fields
    end

    def answer_for_field(field_id)
      attempt.answer_for_field(field_id)
    end

    def photos_for_field(field_id)
      attempt.photos_for_field(field_id)
    end
  end
end

