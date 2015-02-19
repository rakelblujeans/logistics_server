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

ActiveRecord::Schema.define(version: 20141103213811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delivery_types", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipments_id"
  end

  add_index "delivery_types", ["shipments_id"], name: "index_delivery_types_on_shipments_id", using: :btree

  create_table "event_states", force: true do |t|
    t.text "description"
  end

  create_table "events", force: true do |t|
    t.integer  "order_id"
    t.integer  "phone_id"
    t.integer  "event_state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.text     "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.text     "invoice_id"
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
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipments_id"
    t.integer  "events_id"
  end

  add_index "orders", ["events_id"], name: "index_orders_on_events_id", using: :btree
  add_index "orders", ["shipments_id"], name: "index_orders_on_shipments_id", using: :btree

  create_table "orders_phones", id: false, force: true do |t|
    t.integer "phone_id", null: false
    t.integer "order_id", null: false
  end

  add_index "orders_phones", ["order_id"], name: "index_orders_phones_on_order_id", using: :btree
  add_index "orders_phones", ["phone_id"], name: "index_orders_phones_on_phone_id", using: :btree

  create_table "phones", force: true do |t|
    t.integer  "inventory_id"
    t.text     "MEID"
    t.text     "ICCID"
    t.text     "phone_num"
    t.text     "notes"
    t.date     "last_imaged"
    t.boolean  "active"
    t.integer  "provider_id"
    t.integer  "events_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["events_id"], name: "index_phones_on_events_id", using: :btree

  create_table "phones_shipments", id: false, force: true do |t|
    t.integer "phone_id",    null: false
    t.integer "shipment_id", null: false
  end

  add_index "phones_shipments", ["phone_id"], name: "index_phones_shipments_on_phone_id", using: :btree
  add_index "phones_shipments", ["shipment_id"], name: "index_phones_shipments_on_shipment_id", using: :btree

  create_table "providers", force: true do |t|
    t.text     "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phones_id"
  end

  add_index "providers", ["phones_id"], name: "index_providers_on_phones_id", using: :btree

  create_table "shipments", force: true do |t|
    t.text     "delivery_out_code"
    t.text     "hand_delivered_by"
    t.text     "delivery_return_code"
    t.integer  "qty"
    t.boolean  "active"
    t.date     "out_on_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.integer  "delivery_type_id"
  end

end
