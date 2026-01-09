# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_29_000004) do
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attempt_answers", force: :cascade do |t|
    t.integer "challenge_attempt_id", null: false
    t.string "field_id", limit: 255, null: false
    t.text "answer_value"
    t.json "answer_data", default: {}
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_attempt_id", "field_id"], name: "idx_attempt_answers_unique", unique: true
    t.index ["challenge_attempt_id"], name: "index_attempt_answers_on_challenge_attempt_id"
  end

  create_table "attempt_artifacts", force: :cascade do |t|
    t.integer "challenge_attempt_id", null: false
    t.string "kind", limit: 50, null: false
    t.json "metadata", default: {}
    t.string "field_id", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_attempt_id", "field_id"], name: "index_attempt_artifacts_on_challenge_attempt_id_and_field_id"
    t.index ["challenge_attempt_id", "kind"], name: "index_attempt_artifacts_on_challenge_attempt_id_and_kind"
    t.index ["challenge_attempt_id"], name: "index_attempt_artifacts_on_challenge_attempt_id"
  end

  create_table "attempt_statuses", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.boolean "is_final", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_attempt_statuses_on_code", unique: true
  end

  create_table "award_point_levels", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.integer "points", default: 0, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_award_point_levels_on_code", unique: true
  end

  create_table "challenge_attempts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "challenge_id", null: false
    t.integer "attempt_status_id", null: false
    t.integer "score_awarded"
    t.string "evidence_url", limit: 500
    t.datetime "started_at", null: false
    t.datetime "submitted_at"
    t.datetime "reviewed_at"
    t.integer "reviewer_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attempt_status_id"], name: "index_challenge_attempts_on_attempt_status_id"
    t.index ["challenge_id"], name: "index_challenge_attempts_on_challenge_id"
    t.index ["reviewer_user_id"], name: "index_challenge_attempts_on_reviewer_user_id"
    t.index ["user_id", "challenge_id"], name: "index_challenge_attempts_on_user_id_and_challenge_id"
    t.index ["user_id"], name: "index_challenge_attempts_on_user_id"
  end

  create_table "challenge_types", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_challenge_types_on_code", unique: true
  end

  create_table "challenges", force: :cascade do |t|
    t.integer "creator_user_id", null: false
    t.integer "location_id"
    t.integer "challenge_type_id", null: false
    t.integer "difficulty_level_id", null: false
    t.integer "award_point_level_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "fields_config", default: [], null: false
    t.index ["award_point_level_id"], name: "index_challenges_on_award_point_level_id"
    t.index ["challenge_type_id"], name: "index_challenges_on_challenge_type_id"
    t.index ["creator_user_id"], name: "index_challenges_on_creator_user_id"
    t.index ["difficulty_level_id"], name: "index_challenges_on_difficulty_level_id"
    t.index ["is_active"], name: "index_challenges_on_is_active"
    t.index ["location_id"], name: "index_challenges_on_location_id"
    t.index ["title"], name: "index_challenges_on_title"
  end

  create_table "classification_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classifications", comment: "Classifications", force: :cascade do |t|
    t.string "code", limit: 255, null: false, comment: "Classification code"
    t.boolean "system", default: false, comment: "Check whether the classification is a system classification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_classifications_on_code", unique: true
  end

  create_table "difficulty_levels", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.text "description"
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_difficulty_levels_on_code", unique: true
    t.index ["sort_order"], name: "index_difficulty_levels_on_sort_order"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "radius_meters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "order_statuses", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.boolean "is_final", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_order_statuses_on_code", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reward_id", null: false
    t.bigint "order_status_id", null: false
    t.integer "total_points", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_status_id"], name: "index_orders_on_order_status_id"
    t.index ["reward_id", "order_status_id"], name: "index_orders_on_reward_id_and_order_status_id"
    t.index ["reward_id"], name: "index_orders_on_reward_id"
    t.index ["user_id", "created_at"], name: "index_orders_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "code", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_permissions_on_code", unique: true
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.integer "permission_id", null: false
    t.integer "role_id", null: false
    t.index ["permission_id", "role_id"], name: "index_permissions_roles_on_permission_id_and_role_id", unique: true
    t.index ["permission_id"], name: "index_permissions_roles_on_permission_id"
    t.index ["role_id"], name: "index_permissions_roles_on_role_id"
  end

  create_table "points_history", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "delta_points", null: false
    t.string "reason_code", limit: 50, null: false
    t.integer "challenge_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.index ["challenge_id"], name: "index_points_history_on_challenge_id"
    t.index ["created_at"], name: "index_points_history_on_created_at"
    t.index ["order_id"], name: "index_points_history_on_order_id"
    t.index ["reason_code"], name: "index_points_history_on_reason_code"
    t.index ["user_id"], name: "index_points_history_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "owner_user_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description"
    t.integer "cost_points", null: false
    t.boolean "is_active", default: true, null: false
    t.integer "stock_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_points"], name: "index_rewards_on_cost_points"
    t.index ["is_active"], name: "index_rewards_on_is_active"
    t.index ["owner_user_id"], name: "index_rewards_on_owner_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", limit: 100, null: false
    t.text "value"
    t.string "value_type", limit: 50, default: "string", null: false
    t.string "group", limit: 50, default: "general", null: false
    t.string "description", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_settings_on_group"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "first_name", limit: 255, null: false
    t.string "last_name", limit: 255, null: false
    t.string "session_token", limit: 20
    t.string "encrypted_password", default: "", null: false
    t.boolean "blocked", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 45
    t.string "last_sign_in_ip", limit: 45
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role_id"
    t.integer "reward_points", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attempt_answers", "challenge_attempts"
  add_foreign_key "attempt_artifacts", "challenge_attempts"
  add_foreign_key "challenge_attempts", "attempt_statuses"
  add_foreign_key "challenge_attempts", "challenges"
  add_foreign_key "challenge_attempts", "users"
  add_foreign_key "challenge_attempts", "users", column: "reviewer_user_id"
  add_foreign_key "challenges", "award_point_levels"
  add_foreign_key "challenges", "challenge_types"
  add_foreign_key "challenges", "difficulty_levels"
  add_foreign_key "challenges", "locations"
  add_foreign_key "challenges", "users", column: "creator_user_id"
  add_foreign_key "orders", "order_statuses"
  add_foreign_key "orders", "rewards"
  add_foreign_key "orders", "users"
  add_foreign_key "permissions_roles", "permissions"
  add_foreign_key "permissions_roles", "roles"
  add_foreign_key "points_history", "challenges"
  add_foreign_key "points_history", "orders"
  add_foreign_key "points_history", "users"
  add_foreign_key "rewards", "users", column: "owner_user_id"
  add_foreign_key "users", "roles"
end
