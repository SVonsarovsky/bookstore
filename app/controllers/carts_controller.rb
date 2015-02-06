class CartsController < ApplicationController
  before_action :require_login

  def initialize
    super
    @errors = {}
  end

  # GET /cart
  def show
    @cart = current_order
    @cart_items = @cart.order_items.includes(:book).references(:book)
    @subtotal = @cart.total_price
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
  def create
    current_order.add_book(Book.find(params[:book_id].to_i), params[:quantity].to_i)
    flash[:notice] = 'Book was successfully added to cart'
    redirect_to :back
  end

  # PUT /cart
  def update
    if params.has_key?(:quantity)
      update_quantity
    elsif params.has_key?(:address)
      save_addresses
    elsif params.has_key?(:confirm)
      place_order
    end
  end

  # GET /cart/checkout(/:step)
  def checkout
    if params.has_key?(:step)
      step = params[:step]
    else
      step = '1';
    end
    @customer = current_user

    self.send('checkout'+step)
    render 'checkout'+step
  end

  protected

  def update_quantity
    cart = current_order
    params[:quantity].each do |item_id, quantity|
      cart.order_items.find_by(id: item_id).update(:quantity => quantity)
    end
    flash[:notice] = 'Cart was successfully updated'
    redirect_to cart_path
  end

  def save_addresses
    # prepare data for saving
    @customer = current_user
    @order = current_order
    billing_address_params = address_params('billing').merge(user: @customer)
    shipping_address_params = address_params('shipping').merge(user: @customer)

    # save data
    saving_result = save_address('billing', billing_address_params)
    if saving_result
      saving_result = save_address('shipping', shipping_address_params)
    end

    # process result of saving
    if saving_result
      redirect_to cart_checkout_path(2), :notice => 'Your addresses were saved.'
    else
      @countries = Country.order(:name).map{|country| [country.name, country.id]}
      @billing_address = Address.new(billing_address_params)
      @shipping_address = Address.new(shipping_address_params)
      flash[:notice] = 'Unpredictable error occurred while saving addresses.'
      render :checkout1
    end

  end
  def save_address(type, address_params)
    if type == 'billing'
      saving_result = @order.save_address(type, address_params)
    else
      if params.has_key?(:use_billing_address)
        @order.send(type+'_address_id=', @order.billing_address_id)
        saving_result = @order.save
      else
        saving_result = @order.save_address(type, address_params)
      end
    end
    if saving_result
      @customer.send(type+'_address_id=', @order.send("#{type}_address_id"))
      saving_result = @customer.save
      unless saving_result
        @errors["#{type}_address".to_sym] = @customer.errors.full_messages.uniq
      end
    else
      @errors["#{type}_address".to_sym] = @order.errors.full_messages.uniq
    end
    saving_result
  end

  def place_order
    cart = current_order
    cart.update(completed_at: Time.now)
    cart.checkout!
    redirect_to cart_checkout_path(5)
  end

  def checkout1
    @order = current_order
    @billing_address = get_initial_address 'billing'
    @shipping_address = get_initial_address 'shipping'
    @countries = Country.order(:name).map{|country| [country.name, country.id]}
  end
  def checkout2

  end
  def checkout3

  end
  def checkout4
    @order = current_order
    set_order_details
  end
  def checkout5
    @order = Order.get_last_submitted_one(@customer)
    set_order_details
  end

  def set_order_details
    @order_items = @order.order_items.includes(:book).references(:book)
    @credit_card = @order.credit_card
    @billing_address = @order.billing_address
    @shipping_address = @order.shipping_address
  end

  def get_initial_address(type)
    initial_address = @order.send(type+'_address')
    if initial_address.nil?
      initial_address = @customer.send(type+'_address')
    end
    if initial_address.nil?
      initial_address = Address.new
    end
    initial_address
  end
end