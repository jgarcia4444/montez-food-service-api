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

ActiveRecord::Schema[7.0].define(version: 2023_01_25_032830) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "city", default: ""
    t.string "state", default: ""
    t.string "zip_code", default: ""
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street", default: ""
  end

  create_table "admins", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "intuit_accounts", force: :cascade do |t|
    t.text "oauth2_access_token"
    t.datetime "oauth2_access_token_expires_at", precision: nil
    t.text "oauth2_refresh_token"
    t.datetime "oauth2_refresh_token_expires_at", precision: nil
    t.boolean "track_purchase_order_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.string "upc"
    t.string "item"
    t.string "description"
    t.integer "dept"
    t.float "price"
    t.float "case_cost"
    t.float "five_case_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "units_per_case", default: 0
  end

  create_table "ordered_items", force: :cascade do |t|
    t.integer "user_order_id"
    t.integer "quantity"
    t.integer "order_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "case_bought", default: false
  end

  create_table "pending_orders", force: :cascade do |t|
    t.integer "user_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "temp_cart_items", force: :cascade do |t|
    t.integer "temp_cart_id"
    t.integer "order_item_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "temp_carts", force: :cascade do |t|
    t.integer "user_id"
    t.float "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_orders", force: :cascade do |t|
    t.float "total_price"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.string "formatted_address", default: ""
  end

  create_table "users", force: :cascade do |t|
    t.string "company_name"
    t.string "password_digest"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ota_code"
    t.boolean "verified", default: false
    t.boolean "is_ordering", default: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "phone_number", default: ""
    t.integer "address_id"
  end

end
