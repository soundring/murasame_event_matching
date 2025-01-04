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

ActiveRecord::Schema[8.0].define(version: 2024_12_27_064055) do
  create_table "event_group_admins", force: :cascade do |t|
    t.integer "event_group_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_group_id", "user_id"], name: "index_event_group_admins_on_event_group_id_and_user_id", unique: true
    t.index ["event_group_id"], name: "index_event_group_admins_on_event_group_id"
    t.index ["user_id"], name: "index_event_group_admins_on_user_id"
  end

  create_table "event_groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "image_url", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_event_groups_on_name"
    t.index ["user_id"], name: "index_event_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "display_name"
    t.string "profile_picture_url"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_group_admins", "event_groups"
  add_foreign_key "event_group_admins", "users"
  add_foreign_key "event_groups", "users"
end
