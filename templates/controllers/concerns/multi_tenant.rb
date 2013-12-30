module MultiTenant
  extend ActiveSupport::Concern

  included do
    around_filter :scope_current_tenant
    helper_method :current_tenant
  end

  def current_tenant
    current_user.tenant
  end

  def scope_current_tenant
    Tenant.current_id = current_tenant.id
    yield
  ensure
    Tenant.current_id = nil
  end
end