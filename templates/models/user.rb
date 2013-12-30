class User < ActiveRecord::Base
  include MultiTenantModel
  class AuthError < RuntimeError; end

  validates :email, :presence => true, :uniqueness => {:scope => :tenant_id}

  def name
    "#{first_name} #{last_name}"
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    # auth_hash is a OmniAuth::AuthHash
    raise AuthError.new 'Invalid SAML information' unless auth_hash && auth_hash.extra && auth_hash.extra.raw_info

    tenant = Tenant.find_or_create_from_saml(auth_hash.extra.raw_info.selected_account)

    found = User.where(:tenant_id => tenant.id, :email => auth_hash.info.email).first
    found ||= User.new :tenant_id => tenant.id, :email => auth_hash.info.email
    found.first_name   = auth_hash.info.first_name
    found.last_name    = auth_hash.info.last_name
    found.profile_url  = auth_hash.extra.raw_info.profile_url
    found.avatar_url   = auth_hash.extra.raw_info.avatar_url
    found.account_type = auth_hash.extra.raw_info.account_type
    found.save!
    found
  end
end
