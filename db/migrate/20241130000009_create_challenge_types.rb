# frozen_string_literal: true

class CreateChallengeTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :challenge_types do |t|
      t.string :code, limit: 50, null: false
      t.string :name, limit: 100, null: false
      t.text :description

      t.timestamps
    end

    add_index :challenge_types, :code, unique: true
  end
end
