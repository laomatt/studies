class Devise::OmniauthCallbacksController < ApplicationController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
        @path = "/"
      # set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def after_sign_in_path_for(resource)
    @path
  end

end
