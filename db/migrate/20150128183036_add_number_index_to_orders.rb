class AddNumberIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :number, unique: true
  end
end
