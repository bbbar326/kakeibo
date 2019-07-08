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

ActiveRecord::Schema.define(version: 20181010141607) do

  create_table "expenses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pay_accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipt_details", force: :cascade do |t|
    t.integer  "expense_id"
    t.integer  "price"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "receipt_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.date     "date"
    t.integer  "store_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "pay_account_id"
    t.string   "memo"
  end

  create_table "stores", force: :cascade do |t|
    t.string   "name"
    t.string   "tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "tel"], name: "index_stores_on_name_and_tel", unique: true
  end

end