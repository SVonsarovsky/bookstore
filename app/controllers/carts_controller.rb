class CartsController < ApplicationController
  before_action :require_login, :set_order

  # GET /cart
  def show
    @cart_items = @order.books
  end

  # DELETE /cart
  def destroy
    @order.order_items.destroy_all
    redirect_to cart_path
  end

  # DELETE /cart/:item_id
  def remove_item
    @order.order_items.find(params[:item_id]).destroy
    redirect_to cart_path
  end

  # POST /cart
  def create
    @order.add_book(Book.find(params[:book_id].to_i), params[:quantity].to_i)
    redirect_to :back, :notice => 'Book was successfully added to cart.'
  end

  # PUT /cart
  def update
    params[:quantity].each do |item_id, quantity|
      @order.order_items.find_by(id: item_id).update(:quantity => quantity)
    end
    redirect_to cart_path, :notice => 'Cart was successfully updated.'
  end

  private
  def set_order
    @order = current_order
  end
end