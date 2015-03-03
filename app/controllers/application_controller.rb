class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  helper_method :rails_admin?, :categories, :countries, :cart_details

  def rails_admin?
    devise_controller? && resource_name.to_s.downcase == 'admin'
  end

  def categories
    @categories ||= Category.order(:name)
  end

  def countries
    @countries ||= Country.order(:name).map{|country| [country.name, country.id]}
  end

  def cart_details
    order = current_order
    (order.nil? || order.total_items == 0) ? '(EMPTY)' : "(#{order.total_items}) #{ActionController::Base.helpers.number_to_currency(order.total_price)}"
  end

  def after_sign_in_path_for(resource)
    if resource.to_s == 'admin'
      rails_admin_path
    else
      session[:last_open_page] ? session[:last_open_page] : root_path
    end
  end

  def after_sign_out_path_for(resource)
    resource.to_s == 'admin' ? rails_admin_path : root_path
  end

  private
  def layout_by_resource
    rails_admin? ? 'rails_admin' : 'application'
  end

  def current_order
    current_user.order_in_progress unless current_user.nil?
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def last_open_page
    session[:last_open_page] = request.original_fullpath unless user_signed_in?
  end

  def require_login
    last_open_page if request.method == 'GET'
    redirect_to sign_in_path, :notice => 'You must be signed in.' unless user_signed_in?
  end
end
