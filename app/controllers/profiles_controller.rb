# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @presenter = Profiles::ShowPresenter.new(current_user: current_user)
  end
end
