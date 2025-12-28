# frozen_string_literal: true

module Admin
  module Locations
    class Form < ApplicationModelForm
      self.object_class_name = "Location"

      delegate :name, :latitude, :longitude, :radius_meters, :active, to: :object

      def new_record?
        !persisted?
      end
    end
  end
end
