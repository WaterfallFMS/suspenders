require 'spec_helper'

describe Tenant do
  context '#find_or_create_from_saml' do
    let(:tenant_json) {OmniAuth.config.mock_auth[:default].extra.raw_info.selected_account}
    let(:tenant_info) {JSON.parse tenant_json}

    it 'raises a parse error if JSON cannot be read' do
      expect {
        Tenant.find_or_create_from_saml("/\/")
      }.to raise_error JSON::ParserError
    end

    it 'does not create a new tenant if one exists' do
      create :tenant, :uuid => tenant_info['uuid']

      expect {
        Tenant.find_or_create_from_saml tenant_json
      }.to change(Tenant,:count).by(0)
    end

    it 'creates a new tenant' do
      expect {
        Tenant.find_or_create_from_saml tenant_json
      }.to change(Tenant,:count).by(1)
    end

    it 'copies info into the tenant' do
      found = Tenant.find_or_create_from_saml tenant_json
      expect(found.name).to eq tenant_info['name']
      expect(found.uuid).to eq tenant_info['uuid']
    end

    it 'sets the thread safe tenant id' do
      found = Tenant.find_or_create_from_saml tenant_json
      expect(Tenant.current_id).to eq found.id
    end
  end
end
