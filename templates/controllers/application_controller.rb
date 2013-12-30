class ApplicationController < ActionController::Base
  include SamlAuthenticate
  skip_before_filter :require_login, :only => :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    if logged_in?
      redirect_to internal_path
    end
  end

  def internal
  end
end