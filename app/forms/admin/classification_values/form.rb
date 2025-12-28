# frozen_string_literal: true

module Admin
  module ClassificationValues
    class Form < ApplicationModelForm
      self.object_class_name = 'ClassificationValue'

      has_one_decorated :classification, using: :@object

      delegate :classification_id, :code, :value, :active, :classification_title,
        to: :decorated_classification
    end
  end
end
