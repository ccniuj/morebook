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

ActiveRecord::Schema.define(version: 20151229055943) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_tags", force: :cascade do |t|
    t.integer "book_id"
    t.integer "tag_id"
  end

  create_table "books", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "author"
    t.string   "isbn"
    t.string   "publisher"
    t.datetime "publish_date"
    t.string   "language"
    t.string   "page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delete_at"
    t.string   "name_en"
    t.string   "author_en"
    t.text     "author_intro"
    t.text     "outline"
    t.text     "review"
  end

  add_index "books", ["isbn"], name: "index_books_on_isbn", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer "book_id"
    t.integer "user_id"
    t.text    "content"
  end

  create_table "managers", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "managers", ["email"], name: "index_managers_on_email", unique: true, using: :btree
  add_index "managers", ["reset_password_token"], name: "index_managers_on_reset_password_token", unique: true, using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer "book_id"
    t.integer "user_id"
    t.text    "content"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "book_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "is_cover?"
  end

  create_table "profiles", id: false, force: :cascade do |t|
    t.integer  "user_id",             null: false
    t.string   "name"
    t.string   "name_ch"
    t.string   "email"
    t.string   "number"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "selfie_file_name"
    t.string   "selfie_content_type"
    t.integer  "selfie_file_size"
    t.datetime "selfie_updated_at"
    t.text     "description"
  end

  create_table "rates", force: :cascade do |t|
    t.integer "book_id"
    t.integer "user_id"
    t.integer "score"
  end

  create_table "shelf_books", force: :cascade do |t|
    t.integer "shelf_id"
    t.integer "book_id"
    t.integer "user_id"
  end

  add_index "shelf_books", ["book_id", "shelf_id"], name: "index_shelf_books_on_book_id_and_shelf_id", using: :btree

  create_table "shelves", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delete_at"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
  end

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delete_at"
  end

  create_table "user_shelves", force: :cascade do |t|
    t.integer "user_id"
    t.integer "shelf_id"
    t.boolean "is_owner?"
  end

  add_index "user_shelves", ["user_id", "shelf_id"], name: "index_user_shelves_on_user_id_and_shelf_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
