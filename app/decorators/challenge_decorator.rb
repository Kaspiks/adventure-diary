# frozen_string_literal: true

class ChallengeDecorator < ApplicationDecorator
  delegate :title, :description, :is_active, :created_at, :updated_at,
           :creator_user, :location, :challenge_type, :difficulty_level,
           :award_point_level, :challenge_attempts, to: :object

  def status_badge
    is_active ? "Active" : "Inactive"
  end

  def status_color
    is_active ? "emerald" : "slate"
  end

  def type_name
    challenge_type&.name
  end

  def difficulty_name
    difficulty_level&.name
  end

  def points
    award_point_level&.points || 0
  end

  def points_display
    "#{points} pts"
  end

  def location_name
    location&.name || "Any Location"
  end

  def creator_name
    creator_user&.full_name
  end

  def attempts_count
    challenge_attempts.count
  end

  def pending_attempts_count
    challenge_attempts.pending_review.count
  end
end







