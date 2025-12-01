# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @presenter = Home::IndexPresenter.new(current_user: current_user)
  end
end
