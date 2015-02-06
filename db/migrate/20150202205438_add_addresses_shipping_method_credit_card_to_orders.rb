class AddAddressesShippingMethodCreditCardToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billing_address_id, :integer, index: true
    add_column :orders, :shipping_address_id, :integer, index: true
    add_column :orders, :shipping_method_id, :integer, index: true
    add_column :orders, :shipping_cost, :decimal, precision: 10, scale: 4, default: 0
    add_column :orders, :credit_card_id, :integer, index: true
  end
end
