class AddNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :number, :integer, after: :id
  end
end
