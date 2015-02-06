class AddAddressesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_address_id, :integer, index: true
    add_column :users, :shipping_address_id, :integer, index: true
  end
end
