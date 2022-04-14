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

ActiveRecord::Schema.define(version: 2022_04_14_114141) do

  create_table "articles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "supplier_id", null: false
    t.string "number"
    t.string "note"
    t.string "manufacturer"
    t.string "origin"
    t.string "unit"
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "tax", precision: 3, scale: 1, default: "7.0", null: false
    t.decimal "deposit", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "unit_quantity", precision: 4, scale: 1, default: "1.0", null: false
    t.decimal "scale_quantity", precision: 8, scale: 2
    t.decimal "scale_price", precision: 8, scale: 2
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string "category"
    t.index ["name"], name: "index_articles_on_name"
    t.index ["number", "supplier_id"], name: "index_articles_on_number_and_supplier_id", unique: true
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "phone", null: false
    t.string "phone2"
    t.string "fax"
    t.string "email"
    t.string "url"
    t.string "delivery_days"
    t.string "note"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean "ftp_sync", default: false
    t.string "ftp_host"
    t.string "ftp_user"
    t.string "ftp_password"
    t.string "ftp_type", default: "bnn", null: false
    t.string "ftp_regexp", default: "^([.]/)?PL"
    t.boolean "mail_sync"
    t.string "mail_from"
    t.string "mail_subject"
    t.string "mail_type"
    t.string "salt", null: false
    t.index ["name"], name: "index_suppliers_on_name", unique: true
  end

  create_table "user_accesses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["supplier_id"], name: "index_user_accesses_on_supplier_id"
    t.index ["user_id", "supplier_id"], name: "index_user_accesses_on_user_id_and_supplier_id"
    t.index ["user_id"], name: "index_user_accesses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_hash"
    t.string "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
