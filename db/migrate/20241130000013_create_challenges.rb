# frozen_string_literal: true

class CreateChallenges < ActiveRecord::Migration[8.0]
  def change
    create_table :challenges do |t|
      t.references :creator_user, null: false, foreign_key: { to_table: :users }
      t.references :location, null: true, foreign_key: true
      t.references :challenge_type, null: false, foreign_key: true
      t.references :difficulty_level, null: false, foreign_key: true
      t.references :award_point_level, null: false, foreign_key: true
      t.string :title, limit: 255, null: false
      t.text :description
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :challenges, :title
    add_index :challenges, :is_active
  end
end
