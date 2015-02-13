class CheckoutController < ApplicationController
  include FormProcessing
  include Wicked::Wizard
  include CheckoutWizard
  steps :address, :shipping, :payment, :confirm, :complete
  rescue_from Wicked::Wizard::InvalidStepError, with: :render_404
  helper_method :step_index_for, :current_step_index, :wizard_path, :next_wizard_path

  before_action :require_login, :set_data

  def show
    before_show step
    redirect_to previous_wizard_path, :notice => @notice and return unless @notice.nil?
    render_wizard
  end

  def update
    save step
    redirect_to next_wizard_path, :notice => @notice and return if @errors.length == 0
    before_show step
    render_wizard
  end

  protected
  def set_data
    @errors = {}
    @user = current_user
    @order = (step == :complete) ? @user.get_last_placed_order : current_order
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