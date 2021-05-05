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

ActiveRecord::Schema.define(version: 2021_05_05_160125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aozora_authors", force: :cascade do |t|
    t.string "author_uid"
    t.string "last_name"
    t.string "first_name"
    t.string "full_name"
    t.string "last_name_yomi"
    t.string "first_name_yomi"
    t.string "last_name_sort"
    t.string "first_name_sort"
    t.string "last_name_roman"
    t.string "first_name_roman"
    t.date "date_of_birth"
    t.date "date_of_death"
    t.boolean "copyright"
    t.text "outline"
    t.text "wiki_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_uid"], name: "index_aozora_authors_on_author_uid"
    t.index ["first_name"], name: "index_aozora_authors_on_first_name"
    t.index ["first_name_roman"], name: "index_aozora_authors_on_first_name_roman"
    t.index ["first_name_sort"], name: "index_aozora_authors_on_first_name_sort"
    t.index ["first_name_yomi"], name: "index_aozora_authors_on_first_name_yomi"
    t.index ["full_name"], name: "index_aozora_authors_on_full_name"
    t.index ["last_name"], name: "index_aozora_authors_on_last_name"
    t.index ["last_name_roman"], name: "index_aozora_authors_on_last_name_roman"
    t.index ["last_name_sort"], name: "index_aozora_authors_on_last_name_sort"
    t.index ["last_name_yomi"], name: "index_aozora_authors_on_last_name_yomi"
  end

  create_table "aozora_book_authors", force: :cascade do |t|
    t.integer "aozora_author_id"
    t.integer "aozora_book_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aozora_author_id"], name: "index_aozora_book_authors_on_aozora_author_id"
    t.index ["aozora_book_id"], name: "index_aozora_book_authors_on_aozora_book_id"
    t.index ["role"], name: "index_aozora_book_authors_on_role"
  end

  create_table "aozora_books", force: :cascade do |t|
    t.string "book_uid"
    t.string "title"
    t.string "title_yomi"
    t.string "title_sort"
    t.string "subtitle"
    t.string "subtitle_yomi"
    t.string "original_title"
    t.string "font_kana_type"
    t.boolean "copyright"
    t.date "release_date"
    t.date "last_modified"
    t.string "card_url"
    t.string "text_url"
    t.string "html_url"
    t.string "text_encoding"
    t.string "html_encoding"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_uid"], name: "index_aozora_books_on_book_uid"
    t.index ["original_title"], name: "index_aozora_books_on_original_title"
    t.index ["subtitle"], name: "index_aozora_books_on_subtitle"
    t.index ["subtitle_yomi"], name: "index_aozora_books_on_subtitle_yomi"
    t.index ["title"], name: "index_aozora_books_on_title"
    t.index ["title_sort"], name: "index_aozora_books_on_title_sort"
    t.index ["title_yomi"], name: "index_aozora_books_on_title_yomi"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name"
  end

  create_table "datasets", force: :cascade do |t|
    t.integer "label"
    t.integer "house_id"
    t.integer "year"
    t.integer "month"
    t.float "temperature"
    t.float "daylight"
    t.integer "energy_production"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daylight"], name: "index_datasets_on_daylight"
    t.index ["energy_production"], name: "index_datasets_on_energy_production"
    t.index ["house_id"], name: "index_datasets_on_house_id"
    t.index ["label"], name: "index_datasets_on_label"
    t.index ["month"], name: "index_datasets_on_month"
    t.index ["temperature"], name: "index_datasets_on_temperature"
    t.index ["year"], name: "index_datasets_on_year"
  end

  create_table "houses", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "city_text"
    t.integer "city_id"
    t.integer "num_of_people"
    t.boolean "has_child"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_houses_on_city_id"
    t.index ["city_text"], name: "index_houses_on_city_text"
    t.index ["firstname"], name: "index_houses_on_firstname"
    t.index ["has_child"], name: "index_houses_on_has_child"
    t.index ["lastname"], name: "index_houses_on_lastname"
    t.index ["num_of_people"], name: "index_houses_on_num_of_people"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.string "img_url", default: "", null: false
    t.integer "roles_code", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["roles_code"], name: "index_users_on_roles_code"
  end

end
