# frozen_string_literal: true

class CreateAwardPointLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :award_point_levels do |t|
      t.string :code, limit: 50, null: false
      t.string :name, limit: 100, null: false
      t.integer :points, null: false, default: 0
      t.text :description

      t.timestamps
    end

    add_index :award_point_levels, :code, unique: true
  end
end
