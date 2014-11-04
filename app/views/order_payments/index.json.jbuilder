json.array!(@order_payments) do |order_payment|
  json.extract! order_payment, :id, :bt_trans_id, :discount_code, :shipping_string, :referral_code, :rental_charge, :shipping_charge, :rental_discount, :tax_charge, :payment_amount, :payment_date, :payment_status, :discount_string, :last_4_digits, :refunded, :order_id, :credit_card_id
  json.url order_payment_url(order_payment, format: :json)
end
