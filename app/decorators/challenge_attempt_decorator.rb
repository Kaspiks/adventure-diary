# frozen_string_literal: true

class ChallengeAttemptDecorator < ApplicationDecorator
  delegate :user, :challenge, :attempt_status, :reviewer_user, :evidence_url,
           :score_awarded, :started_at, :submitted_at, :reviewed_at,
           :started?, :submitted?, :approved?, :rejected?, :final?, to: :object

  def status_name
    attempt_status&.name
  end

  def status_color
    case attempt_status&.code
    when "started"
      "blue"
    when "submitted"
      "amber"
    when "approved"
      "emerald"
    when "rejected"
      "red"
    else
      "slate"
    end
  end

  def user_name
    user&.full_name
  end

  def challenge_title
    challenge&.title
  end

  def reviewer_name
    reviewer_user&.full_name
  end

  def points_display
    return "-" unless score_awarded

    "#{score_awarded} pts"
  end

  def started_at_formatted
    started_at&.strftime("%B %d, %Y %H:%M")
  end

  def submitted_at_formatted
    submitted_at&.strftime("%B %d, %Y %H:%M")
  end

  def reviewed_at_formatted
    reviewed_at&.strftime("%B %d, %Y %H:%M")
  end
end







