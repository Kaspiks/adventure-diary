# frozen_string_literal: true

module Challenges
  class AwardPoints
    class AlreadyAwardedError < StandardError; end
    class InvalidAttemptError < StandardError; end

    attr_reader :attempt, :points_awarded

    def initialize(attempt:)
      @attempt = attempt
      @points_awarded = 0
    end

    def call
      validate!
      award_points
      Result.new(success: true, points_awarded: points_awarded, errors: [])
    rescue AlreadyAwardedError
      Result.new(success: false, points_awarded: 0, errors: ["Points have already been awarded for this attempt"])
    rescue InvalidAttemptError => e
      Result.new(success: false, points_awarded: 0, errors: [e.message])
    rescue StandardError => e
      Result.new(success: false, points_awarded: 0, errors: [e.message])
    end

    class << self
      # Scoring rules for an attempt (read-only; used by approval and this service).
      def calculate_points_for(attempt)
        if attempt.challenge.has_fields?
          field_score = attempt.calculate_score
          if attempt.challenge.quiz_challenge?
            field_score
          else
            field_score + attempt.challenge.award_points
          end
        else
          attempt.challenge.award_points
        end
      end
    end

    private

    def validate!
      raise InvalidAttemptError, "Attempt must be approved" unless attempt.approved?
      raise AlreadyAwardedError if points_already_awarded?
    end

    def points_already_awarded?
      PointsHistory.exists?(
        user: attempt.user,
        challenge: attempt.challenge,
        reason_code: PointsHistory::REASON_CHALLENGE_AWARD
      )
    end

    def award_points
      @points_awarded = calculate_points

      ActiveRecord::Base.transaction do
        attempt.user.add_points!(
          points_awarded,
          reason_code: PointsHistory::REASON_CHALLENGE_AWARD,
          challenge: attempt.challenge
        )

        attempt.update!(score_awarded: points_awarded)
      end
    end

    def calculate_points
      self.class.calculate_points_for(attempt)
    end

    class Result
      attr_reader :points_awarded, :errors

      def initialize(success:, points_awarded:, errors:)
        @success = success
        @points_awarded = points_awarded
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !success?
      end
    end
  end
end

