# frozen_string_literal: true

class CreateChallengeConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :challenge_configs do |t|
      t.references :challenge, null: false, foreign_key: true, index: { unique: true }
      t.references :challenge_type_schema, null: false, foreign_key: true
      t.json :config_json, null: false, default: {}

      t.timestamps
    end
  end
end

