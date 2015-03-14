class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.find_for_facebook_oauth request.env['omniauth.auth']
    if user.persisted?
      set_flash_message(:notice, :success, :kind => 'Facebook')
      sign_in_and_redirect user, :event => :authentication
    else
      set_flash_message(:notice, :failure, :kind => 'Facebook', reason: '!?')
      redirect_to sign_in_path
    end
  end
end