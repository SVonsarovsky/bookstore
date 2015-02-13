class UsersController < ApplicationController
  include FormProcessing
  before_action :require_login, :set_data

  # GET /user/edit
  def edit
    @billing_address  ||= @user.billing_address  || Address.new
    @shipping_address ||= @user.shipping_address || Address.new
    render :edit
  end

  # PUT /user/update_email
  def update_email
    if @user.update(user_params)
      redirect_to edit_user_path, :notice => 'Your e-mail was updated.'
    else
      set_errors_for 'user', 'email'
      edit
    end
  end

  # PUT /user/update_password
  def update_password
    if @user.update_with_password(user_params)
      redirect_to edit_user_path, :notice => 'Your password was updated.'
    else
      set_errors_for 'user', 'password'
      edit
    end
  end

  # PUT /user/save_address
  def save_address
    type = params[:type] || 'billing'
    if @user.save_address(address_params(type).merge(type: type))
      redirect_to edit_user_path, :notice => 'Your '+type+' address was updated.'
    else
      instance_variable_set("@#{type}_address", Address.new(address_params(type)))
      set_errors_for 'user', type+'_address'
      edit
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
  def set_data
    @user = current_user
    @errors = {}
  end

  def user_params
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
  end
end