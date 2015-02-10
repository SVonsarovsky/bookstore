# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150207165711) do

  create_table "addresses", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "zip_code"
    t.string   "city"
    t.string   "phone"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "addresses", ["country_id"], name: "index_addresses_on_country_id"

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true

  create_table "authors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors_books", id: false, force: true do |t|
    t.integer "author_id"
    t.integer "book_id"
  end

  add_index "authors_books", ["author_id", "book_id"], name: "index_authors_books_on_author_id_and_book_id"
  add_index "authors_books", ["author_id"], name: "index_authors_books_on_author_id"
  add_index "authors_books", ["book_id"], name: "index_authors_books_on_book_id"

  create_table "books", force: true do |t|
    t.string   "title"
    t.text     "short_description"
    t.text     "full_description"
    t.decimal  "price",             precision: 10, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "sold_count",                                 default: 0
  end

  create_table "books_categories", id: false, force: true do |t|
    t.integer "book_id"
    t.integer "category_id"
  end

  add_index "books_categories", ["book_id", "category_id"], name: "index_books_categories_on_book_id_and_category_id"
  add_index "books_categories", ["book_id"], name: "index_books_categories_on_book_id"
  add_index "books_categories", ["category_id"], name: "index_books_categories_on_category_id"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_cards", force: true do |t|
    t.string   "number"
    t.string   "code"
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_cards", ["user_id"], name: "index_credit_cards_on_user_id"

  create_table "order_items", force: true do |t|
    t.decimal  "price",      precision: 10, scale: 4, default: 0.0
    t.integer  "quantity"
    t.integer  "book_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["book_id"], name: "index_order_items_on_book_id"
  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id"

  create_table "orders", force: true do |t|
    t.datetime "completed_at"
    t.integer  "state",                                        default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number"
    t.integer  "billing_address_id"
    t.integer  "shipping_address_id"
    t.integer  "shipping_method_id"
    t.decimal  "shipping_cost",       precision: 10, scale: 4, default: 0.0
    t.integer  "credit_card_id"
  end

  add_index "orders", ["number"], name: "index_orders_on_number", unique: true
  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "reviews", force: true do |t|
    t.text     "text"
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["book_id"], name: "index_reviews_on_book_id"
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id"

  create_table "shipping_methods", force: true do |t|
    t.string   "name"
    t.decimal  "cost",       precision: 10, scale: 4
    t.integer  "state",                               default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "photo"
    t.integer  "billing_address_id"
    t.integer  "shipping_address_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
