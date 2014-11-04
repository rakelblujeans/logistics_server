class CreateOrderPayments < ActiveRecord::Migration
  def change
    create_table :order_payments do |t|
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
      t.references :order, index: true
      t.references :credit_card, index: true

      t.timestamps
    end
  end
end
