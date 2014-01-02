class ApplicationController < ActionController::Base
  include SamlAuthenticate
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  after_filter :verify_authorized,    :except => :index
  after_filter :verify_policy_scoped, :only   => :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

  def user_not_authorized(exception)
    raise exception if Rails.env.test?

    # todo: convert to I18n
    flash.alert = 'You are not authorized to perform this action.'
    redirect_to request.headers["Referer"] || root_path
    false
  end

  # debug checks to ensure we are using policies
  def verify_authorized
    return if Rails.env.production?
    raise 'No authorization used' unless @_policy_authorized
  end

  def verify_policy_scoped
    return if Rails.env.production?
    raise 'No policy scope used' unless @_policy_scoped
  end
end