# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @presenter = Home::IndexPresenter.new(current_user: current_user, view_context: view_context)
  end
end
