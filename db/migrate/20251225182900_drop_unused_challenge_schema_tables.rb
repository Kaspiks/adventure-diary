# frozen_string_literal: true

class DropUnusedChallengeSchemaTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :challenge_configs, if_exists: true
    drop_table :challenge_type_schemas, if_exists: true
  end
end
