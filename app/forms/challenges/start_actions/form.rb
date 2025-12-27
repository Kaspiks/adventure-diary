# frozen_string_literal: true

module Challenges
  module StartActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      def initialize(attempt)
        super(attempt)
      end
    end
  end
end
