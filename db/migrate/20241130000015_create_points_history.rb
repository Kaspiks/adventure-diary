# frozen_string_literal: true

class CreatePointsHistory < ActiveRecord::Migration[8.0]
  def change
    create_table :points_history do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :delta_points, null: false
      t.string :reason_code, limit: 50, null: false
      t.references :challenge, null: true, foreign_key: true
      t.integer :order_id, null: true

      t.datetime :created_at, null: false
    end

    add_index :points_history, :reason_code
    add_index :points_history, :created_at
  end
end
