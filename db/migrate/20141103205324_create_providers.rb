class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.text :name

      t.timestamps
    end
  end
end
