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

ActiveRecord::Schema.define(version: 20141104162019) do

  create_table "credit_cards", force: true do |t|
    t.boolean  "active"
    t.string   "last4"
    t.string   "bt_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_cards", ["customer_id"], name: "index_credit_cards_on_customer_id"

  create_table "customers", force: true do |t|
    t.text     "fname"
    t.text     "lname"
    t.text     "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_payments", force: true do |t|
    t.integer  "bt_trans_id"
    t.text     "discount_code"
    t.text     "shipping_string"
    t.text     "referral_code"
    t.decimal  "rental_charge"
    t.decimal  "shipping_charge"
    t.decimal  "rental_discount"
    t.decimal  "tax_charge"
    t.decimal  "payment_amount"
    t.date     "payment_date"
    t.integer  "payment_status"
    t.text     "discount_string"
    t.text     "last_4_digits"
    t.boolean  "refunded"
    t.integer  "order_id"
    t.integer  "credit_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_payments", ["credit_card_id"], name: "index_order_payments_on_credit_card_id"
  add_index "order_payments", ["order_id"], name: "index_order_payments_on_order_id"

  create_table "order_states", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "order_state"
    t.text     "delivery_type"
    t.text     "full_address"
    t.text     "shipping_name"
    t.text     "shipping_city"
    t.text     "shipping_state"
    t.text     "shipping_zip"
    t.text     "shipping_country"
    t.text     "shipping_apt_suite"
    t.text     "shipping_notes"
    t.date     "arrival_date"
    t.date     "departure_date"
    t.text     "language"
    t.integer  "num_phones"
    t.text     "fedex_out_code"
    t.text     "fedex_return_code"
    t.integer  "customer_id"
    t.integer  "phone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id"
  add_index "orders", ["phone_id"], name: "index_orders_on_phone_id"

  create_table "phones", force: true do |t|
    t.integer  "inventory_id"
    t.text     "MEID"
    t.text     "ICCID"
    t.text     "phone_num"
    t.text     "notes"
    t.date     "last_imaged"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["provider_id"], name: "index_phones_on_provider_id"

  create_table "providers", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
