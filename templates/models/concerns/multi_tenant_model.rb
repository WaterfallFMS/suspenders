module MultiTenantModel
  extend ActiveSupport::Concern

  included do
    belongs_to    :tenant
    default_scope { where(tenant_id: Tenant.current_id) }
  end
end