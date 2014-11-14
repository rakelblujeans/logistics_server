class CreatePhonesOrdersShipments < ActiveRecord::Migration
  def change

    # AT&T, Sprint, etc
    create_table :providers do |t|
      t.text :name
      t.timestamps
      t.references :phones, index: true
    end

    create_table :phones do |t|
      t.integer :inventory_id # our existing id from spreadsheet
      t.text :MEID
      t.text :ICCID
      t.text :phone_num
      t.text :notes
      t.date :last_imaged
      t.belongs_to :provider
      t.timestamps
    end

    create_table :customers do |t|
      t.text :fname
      t.text :lname
      t.text :email
      t.references :shipments, index: true
      t.references :credit_cards, index: true
      t.references :event_logs, index: true
      t.timestamps
    end

    # as it comes in from external source (website)
    create_table :orders do |t|
      t.text :delivery_type_str
      t.text :full_address
      t.text :shipping_name
      t.text :shipping_city
      t.text :shipping_state
      t.text :shipping_zip
      t.text :shipping_country
      t.text :shipping_apt_suite
      t.text :shipping_notes
      t.date :arrival_date
      t.date :departure_date
      t.text :language
      t.integer :num_phones
      t.timestamps
      t.belongs_to :customer
      t.references :shipments, index: true
      t.references :receipts, index: true
    end

    # UPS, Fedex, by hand, etc
    create_table :delivery_types do |t|
      t.text :name
      t.timestamps
      t.references :shipments, index: true
    end

    create_table :shipments do |t|
      t.text :fedex_out_code
      t.text :fedex_return_code
      t.integer :qty
      t.timestamps
      t.belongs_to :order
      t.belongs_to :delivery_type
      t.belongs_to :customer
    end

    # shipment detail
    create_join_table :phones, :shipments do |t|
      t.index :phone_id
      t.index :shipment_id
    end

    create_table :event_logs do |t|
      t.belongs_to :customer
      t.belongs_to :order
      t.text  :description
      t.timestamps
    end

    create_table :credit_cards do |t|
      t.boolean :active
      t.string :last4
      t.string :bt_id
      t.belongs_to :customer
      t.timestamps
      t.references :receipts, index: true
    end

    create_table :receipts do |t|
      t.integer :bt_trans_id
      t.text :discount_code
      t.text :shipping_string
      t.text :referral_code
      t.decimal :rental_charge
      t.decimal :shipping_charge
      t.decimal :rental_discount
      t.decimal :tax_charge
      t.decimal :payment_amount
      t.date :payment_date
      t.integer :payment_status
      t.text :discount_string
      t.text :last_4_digits
      t.boolean :refunded
      t.timestamps
      t.belongs_to :order
      t.belongs_to :credit_card
    end
    
  end
end
