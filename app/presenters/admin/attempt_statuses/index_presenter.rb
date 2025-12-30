# frozen_string_literal: true

module Admin
  module AttemptStatuses
    class IndexPresenter
      attr_reader :attempt_statuses, :search_form

      def initialize(attempt_statuses:, search_form:)
        @attempt_statuses = attempt_statuses
        @search_form = search_form
      end

      def ordered_attempt_statuses
        @ordered_attempt_statuses ||= attempt_statuses.ordered
      end
    end
  end
end

