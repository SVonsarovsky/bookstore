module CommonInForms
  extend ActiveSupport::Concern

  def address_params(type)
    address_params = params.require((type+'_address').to_sym).
        permit(:first_name, :last_name, :address, :city, :country_id, :zip_code, :phone)
    address_params = address_params.merge(user: @user) unless @user.nil?
    address_params
  end

  def set_errors_for(object, property)
    @errors[property.to_sym] = Array.new unless @errors[property.to_sym]
    errors = instance_variable_get("@#{object}").errors.full_messages.uniq
    if errors.length == 0
      entity = instance_variable_get("@#{property}") || instance_variable_get("@#{object}").send(property)
      errors = entity.errors.full_messages.uniq if entity && entity.invalid?
    end
    @errors[property.to_sym] |= errors
  end

end