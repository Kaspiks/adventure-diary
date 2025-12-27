# frozen_string_literal: true

class RemoveRichTextFromSettings < ActiveRecord::Migration[8.0]
  def change
    remove_column :settings, :rich_text, :boolean, null: false, default: false
  end
end






