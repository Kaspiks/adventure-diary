# frozen_string_literal: true

module Admin
  module ClassificationItems
    class IndexPresenter < ApplicationPresenter
      ClassificationItem = Struct.new(:title, :url)

      def initialize(classifications:)
        super()
        @classifications = classifications
      end

      def sorted_classification_items
        all_classifications = classification_items + custom_classification_items

        all_classifications.sort_by { |classification| classification.title }
      end

      private

      def classification_items
        decorate_collection(@classifications).map do |classification|
          ClassificationItem.new(
            classification.title,
            resolved_classification_path(classification)
          )
        end
      end

      def resolved_classification_path(classification)
        default_path = url_helpers.admin_classification_path(classification)
        path_method = "admin_#{classification.code}_path"

        return default_path if classification.code.blank?
        return default_path unless url_helpers.respond_to?(path_method)

        url_helpers.public_send(path_method)
      end

      def custom_classification_items
        [
          ClassificationItem.new(
            t_context('.locations'),
            url_helpers.admin_locations_path
          ),
          ClassificationItem.new(
            t_context('.order_statuses'),
            url_helpers.admin_order_statuses_path
          ),
          ClassificationItem.new(
            t_context('.attempt_statuses'),
            url_helpers.admin_attempt_statuses_path
          )
        ]
      end
    end
  end
end
