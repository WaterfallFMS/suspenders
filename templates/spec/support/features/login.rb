module Features
  include FakePathHelper

  def switch_saml_user(type)
    OmniAuth.config.mock_auth[:saml] = OmniAuth.config.mock_auth[type]
  end

  def login_as(user)
    switch_saml_user user.to_sym

    visit login_path
  end

  def current_user
    @user ||= User.where(
        :email => OmniAuth.config.mock_auth[:saml].info.email
    ).first
  end
end