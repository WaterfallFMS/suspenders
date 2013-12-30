class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :verify_authenticity_token # SAML comes from an external site
  before_filter :check_module_enabled, :only => :create

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)

    auto_login @user
    redirect_back_or_to root_path
  end

  def failure
  end

  def metadata
    settings = Onelogin::Saml::Settings.new({
      :issuer                             => ENV['SAML_IDP_ISSUER'],
      :idp_sso_target_url                 => ENV['SAML_IDP_TARGET_URL'],
      :idp_cert_fingerprint               => ENV['SAML_IDP_CERT_FINGERPRINT'],
      :name_identifier_format             => ENV['SAML_IDP_NAME_FORMAT']
    })
    meta = Onelogin::Saml::Metadata.new
    render :xml => meta.generate(settings)
  end

  #logout
  def destroy
    logout
    redirect_to root_path
  end

private
  def auth_hash
    request.env['omniauth.auth']
  end
  helper_method :auth_hash

  def check_module_enabled
    modules = JSON.parse auth_hash.extra.raw_info.modules_enabled

    raise User::AuthError.new 'Access denied' unless modules.include?('forum')
  end
end