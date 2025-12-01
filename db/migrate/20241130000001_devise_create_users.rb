# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, comment: "Users" do |t|
      t.string :email, limit: 255, null: false, index: { unique: true }
      t.string :first_name, limit: 255, null: false
      t.string :last_name, limit: 255, null: false
      t.string :session_token, limit: 20
      t.string :encrypted_password, null: false, default: ""
      t.boolean :blocked, null: false, default: false
      t.boolean :admin, null: false, default: false
      t.string :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip, limit: 45
      t.string :last_sign_in_ip, limit: 45
      t.integer :failed_attempts, null: false, default: 0
      t.string :unlock_token, index: { unique: true }
      t.datetime :locked_at
      t.timestamps null: false
    end
  end
end
