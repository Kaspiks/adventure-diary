# frozen_string_literal: true

class CreateOrderStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :order_statuses do |t|
      t.string :code, limit: 50, null: false
      t.string :name, limit: 100, null: false
      t.boolean :is_final, default: false, null: false

      t.timestamps
    end

    add_index :order_statuses, :code, unique: true
  end
end

