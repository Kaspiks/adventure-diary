# frozen_string_literal: true

module Profiles
  class ShowPresenter < ApplicationPresenter
    attr_reader :current_user

    has_one_decorated :current_user, using: :current_user, expose: true

    def initialize(current_user:)
      super()
      @current_user = current_user
    end

    def user
      current_user
    end
  end
end
