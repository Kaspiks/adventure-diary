# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true
      t.references :order_status, null: false, foreign_key: true
      t.integer :total_points, null: false

      t.timestamps
    end

    add_index :orders, [:user_id, :created_at]
    add_index :orders, [:reward_id, :order_status_id]
  end
end

