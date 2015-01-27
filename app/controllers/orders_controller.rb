class OrdersController < ApplicationController
  #before_action :require_login

  # POST /cart/add
  def add_item
    require_login('add book to cart')
    cart = get_cart
    cart.add_book(Book.find(params[:book_id].to_i), params[:quantity].to_i)
    flash[:notice] = 'Book was successfully added to cart'
    redirect_to :back
  end

  # DELETE /cart/remove
  def remove_item
    require_login('remove item from cart')
    OrderItem.find_by(order: get_cart, id: params[:item_id]).destroy
    redirect_to cart_path
  end

  # DELETE /cart/empty
  def empty_cart
    require_login('empty cart')
    get_cart.order_items.destroy_all
    redirect_to cart_path
  end

  # PUT /cart/empty
  def update_cart
    require_login('update cart')
    cart = get_cart
    params[:quantity].each do |item_id, quantity|
      cart.order_items.find_by(id: item_id).update(:quantity => quantity)
    end
    flash[:notice] = 'Cart was successfully updated'
    redirect_to cart_path
  end

  # GET /cart
  def cart
    session[:last_open_page] = request.original_fullpath
    require_login('view cart')
    @cart = get_cart
    @cart_items = @cart.order_items.includes(:book).references(:book)
    @subtotal = @cart.total_price
    # @subtotal = @cart.order_items.inject(0){|sum, item| sum + item.quantity*item.price }
  end

  # GET /orders
  def index

  end

  # GET /order/1
  def show

  end

  private
  def require_login(text)
    unless user_signed_in? && current_user.instance_of?(User)
      flash[:notice] = 'You must be signed in to ' + text
      redirect_to sign_in_path
    end
  end

  def get_cart
    Order.get_in_progress_one(current_user)
  end
end