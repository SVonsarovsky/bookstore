class CustomersController < ApplicationController
  before_action :require_login, :set_customer

  # GET /customer/edit
  def edit
    @billing_address = @customer.billing_address.nil? ? Address.new : @customer.billing_address
    @shipping_address = @customer.shipping_address.nil? ? Address.new : @customer.shipping_address
    set_countries
  end

  # PATCH/PUT /customer
  def update
    if params[:user] && params[:user][:email]
      update_email
    elsif params[:user] && params[:user][:password]
      update_password
    elsif params[:billing_address]
      save_address 'billing'
    elsif params[:shipping_address]
      save_address 'shipping'
    else
      redirect_to edit_customer_path
    end
  end

  # DELETE /customer
  def destroy
    if params.has_key?(:remove_account_confirm)
      @customer.destroy
      redirect_to root_path
    else
      redirect_to edit_customer_path, :notice => 'You should confirm your action!'
    end
  end

  private
  def set_customer
    @customer = current_user
    @errors = {}
  end

  def save_address(type = 'billing')
    address_params = address_params(type).merge(user: @customer)
    if @customer.save_address(type, address_params)
      redirect_to edit_customer_path, :notice => 'Your '+type+' address was updated.'
    else
      @errors[(type+'_address').to_sym] = @customer.errors.full_messages.uniq
      edit
      instance_variable_set("@#{type}_address", Address.new(address_params))
      render :edit
    end
  end

  def user_email_param
    params.require(:user).permit(:email)
  end
  def update_email
    if @customer.update(user_email_param)
      redirect_to edit_customer_path, :notice => 'Your e-mail was updated.'
    else
      @errors[:email] = @customer.errors.full_messages.uniq
      edit
      render :edit
    end
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
  def update_password
    if @customer.update_with_password(user_password_params)
      redirect_to edit_customer_path, :notice => 'Your password was updated.'
    else
      @errors[:password] = @customer.errors.full_messages
      edit
      render :edit
    end
  end

end