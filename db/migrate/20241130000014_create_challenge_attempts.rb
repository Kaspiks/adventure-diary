# frozen_string_literal: true

class CreateChallengeAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :challenge_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :challenge, null: false, foreign_key: true
      t.references :attempt_status, null: false, foreign_key: true
      t.integer :score_awarded
      t.string :evidence_url, limit: 500
      t.datetime :started_at, null: false
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.references :reviewer_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :challenge_attempts, [:user_id, :challenge_id]
  end
end
