class OrdersController < ApplicationController
  before_action :require_login

  # GET /orders
  def index
    @order = current_order
    @order_items = @order.order_items.includes(:book).references(:book)
    @orders = Order.get_submitted_ones(current_user)
  end

  # GET /orders/1
  def show
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:book).references(:book)
    @order_total = @order.total_price+@order.shipping_cost
  end
end