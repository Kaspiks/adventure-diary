# frozen_string_literal: true

class RemoveResponsesFromChallengeAttempts < ActiveRecord::Migration[8.0]
  def change
    remove_column :challenge_attempts, :responses, :json, if_exists: true
  end
end
