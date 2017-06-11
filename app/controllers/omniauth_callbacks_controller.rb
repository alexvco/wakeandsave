class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)
        p "<>"*40
        p env["omniauth.auth"]
        session["user_data"] =  env["omniauth.auth"]
        if @user.persisted?
          @user.name = session["user_data"]["info"]["name"]
          @user.profile_picture = session["user_data"]["info"]["image"]

          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          session["user_data"] =  env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end

  # [:twitter, :facebook, :linked_in].each do |provider|
  [:facebook].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      super resourcesessio
    else
      finish_signup_path(resource)
    end
  end

end
