class RemoveTotalPriceTotalItemsFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :total_items, :integer
    remove_column :orders, :total_price, :decimal
  end
end
