class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.decimal :price, precision: 10, scale: 4, default: 0
      t.integer :quantity
      t.belongs_to :book, index: true
      t.belongs_to :order, index: true
      t.timestamps
    end
  end
end
