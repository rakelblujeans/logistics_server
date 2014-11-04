class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.integer :inventory_id
      t.text :MEID
      t.text :ICCID
      t.text :phone_num
      t.text :notes
      t.date :last_imaged
      t.references :provider, index: true

      t.timestamps
    end
  end
end
