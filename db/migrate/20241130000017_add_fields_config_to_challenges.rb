# frozen_string_literal: true

class AddFieldsConfigToChallenges < ActiveRecord::Migration[8.0]
  def change
    add_column :challenges, :fields_config, :jsonb, default: [], null: false
    add_column :challenge_attempts, :responses, :jsonb, default: {}, null: false
  end
end


