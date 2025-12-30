# frozen_string_literal: true

module Admin
  module Rewards
    class ShowPresenter < ApplicationPresenter
      attr_reader :reward

      has_one_decorated :reward, expose: true

      def initialize(reward:)
        super()
        @reward = reward
      end
    end
  end
end

