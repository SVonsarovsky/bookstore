class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  helper_method :rails_admin?, :home_page?, :shop_page?, :cart_page?, :orders_page?, :categories, :cart_details
  #rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def home_page?
    params[:controller] == 'pages' && params[:action] == 'home'
  end

  def shop_page?
    params[:controller] == 'books' && params[:action] == 'index' && !params.has_key?(:category_id)
  end

  def cart_page?
    params[:controller] == 'orders' && params[:action] == 'cart'
  end

  def orders_page?
    params[:controller] == 'orders' && params[:action] == 'index'
  end

  def rails_admin?
    devise_controller? && resource_name.to_s.downcase == 'admin'
  end

  def categories
    puts @categories.nil?
    @categories = Category.order(:name) if @categories.nil?
    @categories
  end

  def cart_details
    order = Order.get_in_progress_one(current_user)
    order.total_items == 0 ? '(EMPTY)' : '(' + order.total_items.to_s+') $' +order.total_price.to_s
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

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  protected
  def layout_by_resource
    rails_admin? ? 'rails_admin' : 'application'
  end
end
