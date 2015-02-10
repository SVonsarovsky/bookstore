class OrdersController < ApplicationController
  before_action :require_login

  # GET /orders
  def index
    @order = current_order
    @order_items = @order.books
    @orders = current_user.get_placed_orders
  end

  # GET /orders/1
  def show
    @order = current_user.orders.find(params[:id])
    @order_items = @order.books
    @order_total = @order.total_price+@order.shipping_cost
  end
end