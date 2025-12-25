# frozen_string_literal: true

class CreateDifficultyLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :difficulty_levels do |t|
      t.string :code, limit: 50, null: false
      t.string :name, limit: 100, null: false
      t.text :description
      t.integer :sort_order, default: 0, null: false

      t.timestamps
    end

    add_index :difficulty_levels, :code, unique: true
    add_index :difficulty_levels, :sort_order
  end
end
