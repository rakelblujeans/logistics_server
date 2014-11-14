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

ActiveRecord::Schema.define(version: 20141103213809) do

  create_table "credit_cards", force: true do |t|
    t.boolean  "active"
    t.string   "last4"
    t.string   "bt_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "receipts_id"
  end

  add_index "credit_cards", ["receipts_id"], name: "index_credit_cards_on_receipts_id"

  create_table "customers", force: true do |t|
    t.text     "fname"
    t.text     "lname"
    t.text     "email"
    t.integer  "shipments_id"
    t.integer  "credit_cards_id"
    t.integer  "event_logs_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["credit_cards_id"], name: "index_customers_on_credit_cards_id"
  add_index "customers", ["event_logs_id"], name: "index_customers_on_event_logs_id"
  add_index "customers", ["shipments_id"], name: "index_customers_on_shipments_id"

  create_table "delivery_types", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipments_id"
  end

  add_index "delivery_types", ["shipments_id"], name: "index_delivery_types_on_shipments_id"

  create_table "event_logs", force: true do |t|
    t.integer  "customer_id"
    t.integer  "order_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.text     "delivery_type_str"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "shipments_id"
    t.integer  "receipts_id"
  end

  add_index "orders", ["receipts_id"], name: "index_orders_on_receipts_id"
  add_index "orders", ["shipments_id"], name: "index_orders_on_shipments_id"

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

  create_table "phones_shipments", id: false, force: true do |t|
    t.integer "phone_id",    null: false
    t.integer "shipment_id", null: false
  end

  add_index "phones_shipments", ["phone_id"], name: "index_phones_shipments_on_phone_id"
  add_index "phones_shipments", ["shipment_id"], name: "index_phones_shipments_on_shipment_id"

  create_table "providers", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phones_id"
  end

  add_index "providers", ["phones_id"], name: "index_providers_on_phones_id"

  create_table "receipts", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.integer  "credit_card_id"
  end

  create_table "shipments", force: true do |t|
    t.text     "fedex_out_code"
    t.text     "fedex_return_code"
    t.integer  "qty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.integer  "delivery_type_id"
    t.integer  "customer_id"
  end

end
