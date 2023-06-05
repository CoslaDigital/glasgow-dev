class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    sign_in_with :twitter_login, :twitter
  end

  def facebook
    sign_in_with :facebook_login, :facebook
  end

  def google_oauth2
    sign_in_with :google_login, :google_oauth2
  end

  def wordpress_oauth2
    sign_in_with :wordpress_login, :wordpress_oauth2
  end

  def saml
    sign_in_with :saml_login, :saml
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      super(resource)
    end
  end

  private

    def sign_in_with(feature, provider)
      raise ActionController::RoutingError, "Not Found" unless Setting["feature.#{feature}"]

      auth = request.env["omniauth.auth"]

      identity = Identity.first_or_create_from_oauth(auth)
#      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_user_for_provider(provider, auth)

      if save_user
        identity.update!(user: @user)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = auth
        redirect_to new_user_registration_path
      end
    end

    def save_user
      @user.save || @user.save_requiring_finish_signup
    end

def initialize_user_for_provider(provider, auth)
  case provider
  when :twitter
    User.first_or_initialize_for_twitter(auth)
  when :saml
    User.first_or_initialize_for_saml(auth)
  else
    User.first_or_initialize_for_oauth(auth)
  end
end

end
