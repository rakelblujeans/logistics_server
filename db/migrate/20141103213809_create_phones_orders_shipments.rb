class CreatePhonesOrdersShipments < ActiveRecord::Migration
  def change

    create_table :languages do |t|
      t.text :name
      t.boolean :active
      t.timestamps
    end

    # AT&T, Sprint, etc
    create_table :providers do |t|
      t.text :name
      t.boolean :active
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
      t.boolean :active
      t.belongs_to :provider
      t.references :events, index: true
      t.timestamps
    end

    create_table :customers do |t|
      t.text :fname
      t.text :lname
      t.text :email
      t.text :bt_id
      t.boolean :active
      t.references :shipments, index: true
      t.references :credit_cards, index: true
      t.references :events, index: true
      t.timestamps
    end

    # as it comes in from external source (website)
    create_table :orders do |t|
      t.text :invoice_id
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
      t.boolean :active
      t.timestamps
      t.belongs_to :customer
      t.references :shipments, index: true
      t.references :receipts, index: true
      t.references :events, index: true
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
      t.boolean :active
      t.date :out_on_date
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

    create_table :event_states do |t|
      t.text :description
    end

    create_table :events do |t|
      t.belongs_to :customer
      t.belongs_to :order
      t.belongs_to :phone
      t.belongs_to :event_state
      t.timestamps
    end

    create_table :credit_cards do |t|
      t.string :last4
      t.string :bt_id
      t.boolean :active
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
      t.boolean :active
      t.timestamps
      t.belongs_to :order
      t.belongs_to :credit_card
    end
    
  end
end