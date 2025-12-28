# frozen_string_literal: true

module Admin
  class ClassificationsController < BaseController
    def show
      classification = Classification.find(params[:id])
      
      authorize([:admin, classification])

      @presenter = Admin::Classifications::ShowPresenter.new(current_user, classification)
    end
  end
end
