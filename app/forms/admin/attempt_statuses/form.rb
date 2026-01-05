# frozen_string_literal: true

module Admin
  module AttemptStatuses
    class Form < ApplicationModelForm
      self.object_class_name = "AttemptStatus"

      delegate :code, :name, :is_final, to: :object

      def new_record?
        !persisted?
      end
    end
  end
end

