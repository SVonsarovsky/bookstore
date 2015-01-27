class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.decimal :total_price, precision: 10, scale: 4, default: 0
      t.integer :total_items, default: 0
      t.datetime :completed_at
      t.integer :state, default: 0
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
