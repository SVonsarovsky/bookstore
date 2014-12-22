class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  helper_method :rails_admin?

  def rails_admin?
    devise_controller? && resource_name.to_s.downcase == 'admin'
  end

  def after_sign_out_path_for(resource)
    resource.to_s == 'admin' ? rails_admin_path : root_path
  end

  protected
  def layout_by_resource
    rails_admin? ? 'rails_admin' : 'application'
  end
end
