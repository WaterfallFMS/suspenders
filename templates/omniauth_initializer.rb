Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
    :issuer                             => ENV['SAML_IDP_ISSUER'],
    :idp_sso_target_url                 => ENV['SAML_IDP_TARGET_URL'],
    :idp_cert_fingerprint               => ENV['SAML_IDP_CERT_FINGERPRINT'],
    :name_identifier_format             => ENV['SAML_IDP_NAME_FORMAT']
end

OmniAuth.config.logger = Rails.logger
