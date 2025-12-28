# frozen_string_literal: true

class CreateClassifications < ActiveRecord::Migration[8.0]
  def change
    create_table :classifications, comment: "Classifications" do |t|
      t.string :code, null: false, comment: "Classification code", limit: 255, index: { unique: true }
      t.boolean :system, default: false, comment: "Check whether the classification is a system classification"
      
      t.timestamps
    end
  end
end
