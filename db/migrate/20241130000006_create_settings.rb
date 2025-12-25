# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings, comment: "Application settings" do |t|
      t.string :key, null: false, limit: 100, index: { unique: true }
      t.text :value
      t.string :value_type, null: false, limit: 50, default: "string"
      t.string :group, null: false, limit: 50, default: "general"
      t.string :description, limit: 500
      t.boolean :rich_text, null: false, default: false

      t.timestamps
    end

    add_index :settings, :group
  end
end







