class OrdersController < ApplicationController
  before_action :require_login

  # GET /orders
  def index
    @order = current_order
    @order_items = @order.order_items.includes(:book).references(:book)
    @subtotal = @order.total_price
    @orders = current_user.orders.where.not(:state => 'in progress').order(state: :asc, completed_at: :desc)
  end

  # GET /orders/1
  def show
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:book).references(:book)
    @subtotal = @order.total_price
    @shipping = 5.99
    @order_total = @subtotal+@shipping
  end
end