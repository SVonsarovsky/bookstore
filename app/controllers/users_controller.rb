class UsersController < ApplicationController
  before_action :require_login, :set_user

  def initialize
    super
    @errors = {}
  end

  # GET /user/edit
  def edit
    @billing_address ||= @user.billing_address.nil? ? Address.new : @user.billing_address
    @shipping_address ||= @user.shipping_address.nil? ? Address.new : @user.shipping_address
    render :edit
  end

  # PATCH/PUT /user
  def update
    if params[:user] && params[:user][:email]
      update_email
    elsif params[:user] && params[:user][:password]
      update_password
    elsif params[:billing_address]
      save_address 'billing'
    elsif params[:shipping_address]
      save_address 'shipping'
    end
  end

  # DELETE /user
  def destroy
    if params.has_key?(:remove_account_confirm)
      @user.destroy
      redirect_to root_path
    else
      redirect_to edit_user_path, :notice => 'You should confirm your action!'
    end
  end

  private
  def set_user
    @user = current_user
  end

  def save_address(type = 'billing')
    address_params = address_params(type).merge(user: @user)
    if @user.save_address(type, address_params)
      redirect_to edit_user_path, :notice => 'Your '+type+' address was updated.'
    else
      instance_variable_set("@#{type}_address", Address.new(address_params))
      set_area_errors type+'_address', 'user'
      edit
    end
  end

  def update_email
    if @user.update(params.require(:user).permit(:email))
      redirect_to edit_user_path, :notice => 'Your e-mail was updated.'
    else
      set_area_errors 'email', 'user'
      edit
    end
  end

  def update_password
    password_params = params.require(:user).permit(:current_password, :password, :password_confirmation)
    if @user.update_with_password(password_params)
      redirect_to edit_user_path, :notice => 'Your password was updated.'
    else
      set_area_errors 'password', 'user'
      edit
    end
  end

end