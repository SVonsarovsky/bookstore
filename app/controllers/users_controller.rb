class UsersController < ApplicationController
  before_action :require_login, :set_user

  # GET /user/edit
  def edit
    @billing_address = @user.billing_address.nil? ? Address.new : @user.billing_address
    @shipping_address = @user.shipping_address.nil? ? Address.new : @user.shipping_address
    set_countries
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
    else
      redirect_to edit_user_path
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
    @errors = {}
  end

  def save_address(type = 'billing')
    address_params = address_params(type).merge(user: @user)
    if @user.save_address(type, address_params)
      redirect_to edit_user_path, :notice => 'Your '+type+' address was updated.'
    else
      errors = @user.errors.full_messages.uniq
      errors = @user.send(type+'_address').errors.full_messages.uniq unless errors.length > 0
      @errors[(type+'_address').to_sym] = errors
      edit
      instance_variable_set("@#{type}_address", Address.new(address_params))
      render :edit
    end
  end

  def user_email_param
    params.require(:user).permit(:email)
  end
  def update_email
    if @user.update(user_email_param)
      redirect_to edit_user_path, :notice => 'Your e-mail was updated.'
    else
      @errors[:email] = @user.errors.full_messages.uniq
      edit
      render :edit
    end
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
  def update_password
    if @user.update_with_password(user_password_params)
      redirect_to edit_user_path, :notice => 'Your password was updated.'
    else
      @errors[:password] = @user.errors.full_messages
      edit
      render :edit
    end
  end

end