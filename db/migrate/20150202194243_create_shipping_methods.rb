class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.string :name
      t.decimal :cost, precision: 10, scale: 4
      t.integer :state, default: 1

      t.timestamps
    end
  end
end
