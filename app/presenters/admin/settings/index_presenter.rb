# frozen_string_literal: true

module Admin
  module Settings
    class IndexPresenter < ApplicationPresenter
      attr_reader :settings, :current_group

      def initialize(settings:, current_group: nil)
        @settings = settings
        @current_group = current_group || Setting::GROUPS.first
      end

      def grouped_settings
        @grouped_settings ||= settings.grouped
      end

      def groups
        Setting::GROUPS
      end

      def current_group_settings
        grouped_settings[@current_group] || []
      end

      def group_count(group)
        grouped_settings[group]&.size || 0
      end

      def total_count
        settings.count
      end
    end
  end
end





