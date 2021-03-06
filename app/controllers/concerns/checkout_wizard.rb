module CheckoutWizard
  extend ActiveSupport::Concern

  def before_show(step)
    self.send("before_#{step}_show")
  end

  def save(step)
    self.send("process_#{step}")
  end

  def before_address_show
    init_address 'billing'
    init_address 'shipping'
  end

  def before_shipping_show
    if @order.billing_address_id.nil? || @order.shipping_address_id.nil?
      @notice = 'Your order addresses have not been set in correct way yet!'
      return
    end
    @shipping_methods = ShippingMethod.active
    shipping_method_id = params[:shipping_method_id] || @order.shipping_method_id
    unless shipping_method_id
      @shipping_method = @shipping_methods.first
    else
      @shipping_method = @shipping_methods.select{|shipping_method| shipping_method.id == shipping_method_id }.first
    end
  end

  def before_payment_show
    if @order.shipping_method_id.nil?
      @notice = 'Shipping method has not been set yet!'
      return
    end
    @credit_card ||= @order.credit_card || @user.last_credit_card || CreditCard.new
  end

  def before_confirm_show
    @notice = 'Credit card details have not been saved!' if @order.credit_card_id.nil?
  end

  def before_complete_show
    @notice = 'Order processing has not been finished yet!' if @order.nil?
  end

  def process_address
    if (save_address('billing') && save_address('shipping'))
      @notice = 'Your addresses have been saved.'
    else
      @billing_address  = Address.new(address_params('billing'))
      set_errors_for 'order', 'billing_address'  if @billing_address.invalid?
      @shipping_address = Address.new(address_params('shipping'))
      set_errors_for 'order', 'shipping_address' if @shipping_address.invalid?
    end
  end

  def process_shipping
    if @order.update(shipping_params)
      @notice = 'Shipping method was successfully saved.'
    else
      set_errors_for 'order', 'shipping_method'
    end
  end

  def process_payment
    if @order.save_credit_card(credit_card_params)
      @notice = 'Payment data was successfully saved.'
    else
      @credit_card = CreditCard.new(credit_card_params)
      set_errors_for 'order', 'credit_card'
    end
  end

  def process_confirm
    @order.checkout!
  end

  def process_complete
  end

  private
  def init_address(type)
    address = instance_variable_get "@#{type}_address"
    instance_variable_set("@#{type}_address",
                          @order.send(type+'_address') || @user.send(type+'_address') || Address.new) if address.nil?
  end

  def save_address(type)
    if type == 'shipping' && params.has_key?(:use_billing_address)
      @order.send(type+'_address_id=', @order.billing_address_id)
      return @order.save
    end
    unless @user.save_address(address_params(type).merge(type: type))
      set_errors_for 'user', "#{type}_address"
      return false
    end
    @order.send(type+'_address_id=', @user.send("#{type}_address_id"))
    @order.save
  end

  def shipping_params
    params.permit(:shipping_method_id, :shipping_cost)
  end

  def credit_card_params
    credit_card_params = params.require(:credit_card).permit(:number, :expiration_month, :expiration_year, :code)
    credit_card_params = credit_card_params.merge(user: @user) unless @user.nil?
    credit_card_params
  end

end