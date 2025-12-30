# frozen_string_literal: true

class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.references :owner_user, null: false, foreign_key: { to_table: :users }
      t.string :title, limit: 255, null: false
      t.text :description
      t.integer :cost_points, null: false
      t.boolean :is_active, default: true, null: false
      t.integer :stock_quantity

      t.timestamps
    end

    add_index :rewards, :is_active
    add_index :rewards, :cost_points
  end
end

