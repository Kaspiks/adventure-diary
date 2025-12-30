# frozen_string_literal: true

class AddOrderToPointsHistory < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :points_history, :orders, column: :order_id
    add_index :points_history, :order_id
  end
end

