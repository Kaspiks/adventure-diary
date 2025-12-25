# frozen_string_literal: true

class CreateChallengeTypeSchemas < ActiveRecord::Migration[8.0]
  def change
    create_table :challenge_type_schemas do |t|
      t.references :challenge_type, null: false, foreign_key: true
      t.integer :version, null: false, default: 1
      t.json :schema_json, null: false
      t.json :ui_schema_json
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :challenge_type_schemas, [:challenge_type_id, :version], unique: true
    add_index :challenge_type_schemas, [:challenge_type_id, :active], where: "active = true"
  end
end

