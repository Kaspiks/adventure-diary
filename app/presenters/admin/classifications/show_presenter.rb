# frozen_string_literal: true

module Admin
  module Classifications
    class ShowPresenter < ApplicationPresenter
      has_one_decorated :classification, using: :@classification, expose: true

      def initialize(user, classification)
        super()
        @user = user
        @classification = classification
      end

      def sorted_classification_values
        decorate_collection(@classification.classification_values).
          sort_by { |value| value.title_with_state }
      end

      def can_edit?
        Admin::ClassificationPolicy.new(
          @user,
          @classification
        ).edit?
      end
    end
  end
end
