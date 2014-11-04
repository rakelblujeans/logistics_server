class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.boolean :active
      t.string :last4
      t.string :bt_id
      t.references :customer, index: true

      t.timestamps
    end
  end
end
