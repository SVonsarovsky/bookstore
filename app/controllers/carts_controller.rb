class CartsController < ApplicationController
  before_action :require_login, :set_order
  skip_before_filter :set_order, :only => [:checkout]

  def initialize
    super
    @errors = {}
  end

  # GET /cart
  def show
    @cart_items = @order.order_items.includes(:book).references(:book)
    @subtotal = @order.total_price
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
    flash[:notice] = 'Book was successfully added to cart'
    redirect_to :back
  end

  # PUT /cart
  def update
    if params.has_key?(:quantity)
      update_quantity
    elsif params.has_key?(:address)
      save_addresses
    elsif params.has_key?(:shipping)
      save_shipping_method
    elsif params.has_key?(:payment)
      save_payment_data
    elsif params.has_key?(:confirm)
      place_order
    end
  end

  # GET /cart/checkout(/:step)
  def checkout
    @customer = current_user
    step = params.has_key?(:step) ? params[:step] : '1'
    @order = (step == '5') ? Order.get_last_submitted_one(@customer) : current_order
    self.send('checkout'+step)
  end

  private
  def update_quantity
    params[:quantity].each do |item_id, quantity|
      @order.order_items.find_by(id: item_id).update(:quantity => quantity)
    end
    flash[:notice] = 'Cart was successfully updated'
    redirect_to cart_path
  end

  def checkout1
    @billing_address = get_initial_address 'billing'
    @shipping_address = get_initial_address 'shipping'
    set_countries
    render :checkout1
  end

  def save_addresses
    @customer = current_user
    billing_address_params = address_params('billing').merge(user: @customer)
    shipping_address_params = address_params('shipping').merge(user: @customer)

    saving_result = save_address('billing', billing_address_params)
    if saving_result
      saving_result = save_address('shipping', shipping_address_params)
    end

    if saving_result
      redirect_to cart_checkout_path(2), :notice => 'Your addresses were saved.'
    else
      @countries = Country.order(:name).map{|country| [country.name, country.id]}
      @billing_address = Address.new(billing_address_params)
      @shipping_address = Address.new(shipping_address_params)
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

  def checkout2
    if @order.billing_address_id.nil? || @order.shipping_address_id.nil?
      redirect_to cart_checkout_path, :notice => 'Your order addresses have not been set in correct way yet!'
      return
    end
    @shipping_methods = ShippingMethod.active
    if params.has_key?(:shipping_method_id)
      @shipping_method = @shipping_methods.select{|shipping| shipping.id == params[:shipping_method_id] }.first
    elsif !@order.shipping_method_id.nil?
      @shipping_method = @shipping_methods.select{|shipping| shipping.id == @order.shipping_method_id }.first
    end
    @shipping_method = @shipping_methods.first if @shipping_method.nil?
    render :checkout2
  end

  def save_shipping_method
    if @order.update(params.permit(:shipping_method_id, :shipping_cost))
      redirect_to cart_checkout_path(3), :notice => 'Shipping method was successfully saved.'
    else
      @errors[:shipping_method] = @order.errors.full_messages.uniq
      checkout2
    end
  end

  def checkout3
    if @order.shipping_method_id.nil?
      redirect_to cart_checkout_path(2), :notice => 'Shipping method has not been set yet!'
      return
    end
    @credit_card = CreditCard.find_by(user: @customer, id: @order.credit_card_id)
    @credit_card = CreditCard.where(user: @customer).order('id DESC').first if @credit_card.nil?
    @credit_card = CreditCard.new if @credit_card.nil?
    render :checkout3
  end

  def save_payment_data
    @customer = current_user
    if @order.save_credit_card(credit_card_params.merge(user: @customer))
      redirect_to cart_checkout_path(4), :notice => 'Payment data was successfully saved.'
    else
      @errors[:credit_card] = @order.errors.full_messages.uniq
      @credit_card = CreditCard.new(credit_card_params)
      render :checkout3
    end
  end

  def checkout4
    if @order.credit_card_id.nil?
      redirect_to cart_checkout_path(3), :notice => 'Credit card details have not been saved!'
      return
    end
    set_order_details
    render :checkout4
  end

  def place_order
    @order.update(completed_at: Time.now)
    @order.checkout!
    redirect_to cart_checkout_path(5)
  end

  def checkout5
    if @order.nil?
      redirect_to cart_checkout_path(4), :notice => 'Order processing has not been finished yet!' if @order.nil?
      return
    end
    set_order_details
    render :checkout5
  end

  def set_order
    @order = current_order
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

  def credit_card_params
    params.require(:credit_card).permit(:number, :expiration_month, :expiration_year, :code)
  end
end