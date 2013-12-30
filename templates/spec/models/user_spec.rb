require 'spec_helper'

describe User do
  context '#find_or_create_from_auth_hash' do
    let(:auth_hash) {OmniAuth.config.mock_auth[:default]}
    let(:tenant_info) {JSON.parse auth_hash.extra.raw_info.selected_account}

    it 'finds the user by email' do
      tenant = create :tenant, tenant_info.symbolize_keys
      user   = create :user, tenant: tenant, email: auth_hash.info.email

      expect(User.find_or_create_from_auth_hash(auth_hash)).to eq user
    end

    it 'creates a tenant for the user' do
      expect {
        User.find_or_create_from_auth_hash(auth_hash)
      }.to change(Tenant,:count).by(1)
    end

    it 'creates users that do not exits' do
      expect {
        User.find_or_create_from_auth_hash(auth_hash)
      }.to change(User,:count).by(1)
    end

    it 'raises an error if the auth_hash cannot be read' do
      expect {
        User.find_or_create_from_auth_hash(nil)
      }.to raise_error User::AuthError
    end

    it 'copies info into the user' do
      user = User.find_or_create_from_auth_hash(auth_hash)
      expect(user.email).to eq auth_hash.info.email
      expect(user.first_name).to eq auth_hash.info.first_name
      expect(user.last_name).to eq auth_hash.info.last_name
      expect(user.tenant.uuid).to eq tenant_info['uuid']
    end
  end
end
