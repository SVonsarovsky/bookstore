class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  helper_method :rails_admin?, :categories, :countries, :cart_details
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

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
    (order.nil? || order.total_items == 0) ? '(EMPTY)' : '(' + order.total_items.to_s+') $' +order.total_price.to_s
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
    current_user.get_order_in_progress unless current_user.nil?
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def last_open_page
    unless user_signed_in?
      session[:last_open_page] = request.original_fullpath
    end
  end

  def require_login(text = '')
    last_open_page if request.method == 'GET'
    unless user_signed_in?
      flash[:notice] = 'You must be signed in' + (text.length > 0 ? ' to ' + text : '')
      redirect_to sign_in_path
    end
  end

  def address_params(type = 'billing')
    params.require((type+'_address').to_sym).
        permit(:first_name, :last_name, :address, :city, :country_id, :zip_code, :phone)
  end

  def set_area_errors(area, obj = 'order')
    errors = instance_variable_get("@#{obj}").errors.full_messages.uniq
    errors = instance_variable_get("@#{obj}").send(area).errors.full_messages.uniq unless errors.length > 0
    @errors[area.to_sym] = errors
  end

end
