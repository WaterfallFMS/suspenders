OmniAuth.config.test_mode = true

SAML_LOGINS = {
    default:         :foo,
    invalid:         :invalid_credentials,
    waterfall_admin: :bar,
    account_admin:   :baz,
}

# provide a default working user
OmniAuth.config.mock_auth[:saml] = SAML_LOGINS[:default]
