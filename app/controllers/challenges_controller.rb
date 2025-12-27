# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge, only: [:show]

  def index
    @presenter = Challenges::IndexPresenter.new(
      challenges: policy_scope(Challenge).includes(:challenge_type, :difficulty_level, :award_point_level, :location).ordered,
      current_user: current_user
    )
  end

  def show
    authorize @challenge
    @presenter = Challenges::ShowPresenter.new(challenge: @challenge, current_user: current_user)
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end
end
