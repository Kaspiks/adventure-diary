# frozen_string_literal: true

class CreateClassificationValues < ActiveRecord::Migration[8.0]
  def change
    create_table :classification_values, comment: "Classification values" do |t|
      t.references :classification,
        foreign_key: true,
        null: false,
        comment: "Reference to the classification" 

      t.string :value,
        null: false,
        comment: "Classification value",
        limit: 4000

      t.boolean :active,
        null: false,
        default: false,
        comment: "Check whether the classification value is active"

      t.string :system_code,
        null: false,
        comment: "System code",
        limit: 255

      t.timestamps
    end
  end
end
