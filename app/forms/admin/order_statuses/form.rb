# frozen_string_literal: true

module Admin
  module OrderStatuses
    class Form < ApplicationModelForm
      self.object_class_name = "OrderStatus"

      delegate :code, :name, :is_final, to: :object

      def new_record?
        !persisted?
      end
    end
  end
end

