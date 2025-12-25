# frozen_string_literal: true

class CreateAttemptArtifacts < ActiveRecord::Migration[8.0]
  def change
    create_table :attempt_artifacts do |t|
      t.references :challenge_attempt, null: false, foreign_key: true
      t.string :kind, limit: 50, null: false
      t.json :metadata, default: {}
      t.string :field_id, limit: 255

      t.timestamps
    end

    add_index :attempt_artifacts, [:challenge_attempt_id, :kind]
    add_index :attempt_artifacts, [:challenge_attempt_id, :field_id]
  end
end

