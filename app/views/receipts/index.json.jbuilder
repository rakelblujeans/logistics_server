json.array!(@receipts) do |receipt|
  json.extract! receipt, :id, :bt_trans_id, :discount_code, :shipping_string, :referral_code, :rental_charge, :shipping_charge, :rental_discount, :tax_charge, :payment_amount, :payment_date, :payment_status, :discount_string, :last_4_digits, :refunded
  json.url receipt_url(receipt, format: :json)
end
