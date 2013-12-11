# The flow of this module is taken from Sorcery
module SamlAuthenticate
  extend ActiveSupport::Concern

  included do
    before_filter :require_login
    helper_method :login_path
    helper_method :current_user
  end

  def login_path
    '/auth/saml'
  end

  def require_login
    if !logged_in?
      session[:return_to_url] = request.url if request.get?

      redirect_to login_path
    end
  end

  def logged_in?
    !!current_user
  end

  def current_user
    return false if @current_user == false

    @current_user ||= login_from_session
  end

  def login_from_session
    @current_user = (User.find(session[:user_id]) if session[:user_id]) || false
  rescue ActiveRecord::RecordNotFound
    false
  end

  def auto_login(user)
    session[:user_id] = user.id
    @current_user = user
  end
  alias_method :current_user=, :auto_login

  def redirect_back_or_to(url)
    redirect_to(session[:return_to_url] || url)
    session[:return_to_url] = nil
  end

  def logout
    if logged_in?
      @current_user = current_user if @current_user.nil?
      reset_saml_session
      @current_user = nil
    end
  end

  def reset_saml_session
    reset_session
  rescue NoMethodError
    #just incase the reset_session function isn't loaded correctly
  end
end