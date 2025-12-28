# frozen_string_literal: true

module Admin
  class ClassificationItemsController < BaseController
    def index
      authorize([:admin, :classification_item])

      @presenter = Admin::ClassificationItems::IndexPresenter.new(classifications: Classification.all)
    end
  end
end
