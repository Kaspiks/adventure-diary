# frozen_string_literal: true

class CreateAttemptAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :attempt_answers do |t|
      t.references :challenge_attempt, null: false, foreign_key: true
      t.string :field_id, limit: 255, null: false
      t.text :answer_value
      t.json :answer_data, default: {}
      t.boolean :is_correct

      t.timestamps
    end

    add_index :attempt_answers, [:challenge_attempt_id, :field_id], unique: true, name: 'idx_attempt_answers_unique'
  end
end

