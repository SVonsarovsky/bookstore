class CartsController < ApplicationController
  before_action :require_login

  # GET /cart
  def show
    @cart = current_order
    @cart_items = @cart.order_items.includes(:book).references(:book)
    @subtotal = @cart.total_price
  end

  # PUT /cart
  def update
    cart = current_order
    params[:quantity].each do |item_id, quantity|
      cart.order_items.find_by(id: item_id).update(:quantity => quantity)
    end
    flash[:notice] = 'Cart was successfully updated'
    redirect_to cart_path
  end

  # DELETE /cart
  def destroy
    current_order.order_items.destroy_all
    redirect_to cart_path
  end

  # DELETE /cart/:item_id
  def remove_item
    current_order.order_items.find(params[:item_id]).destroy
    redirect_to cart_path
  end

  # POST /cart
  def add_item
    current_order.add_book(Book.find(params[:book_id].to_i), params[:quantity].to_i)
    flash[:notice] = 'Book was successfully added to cart'
    redirect_to :back
  end

end