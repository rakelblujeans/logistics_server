class CreateOrderStates < ActiveRecord::Migration
  def change
    create_table :order_states do |t|
      t.text :name

      t.timestamps
    end
  end
end
