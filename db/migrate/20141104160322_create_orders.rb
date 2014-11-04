class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :order_state
      t.text :delivery_type
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
      t.text :fedex_out_code
      t.text :fedex_return_code
      t.references :customer, index: true
      t.references :phone, index: true

      t.timestamps
    end
  end
end
