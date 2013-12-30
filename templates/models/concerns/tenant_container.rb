module TenantContainer
  extend ActiveSupport::Concern

  module ClassMethods
    def current_id=(id)
      Thread.current[:tenant_id] = id
    end

    def current_id
      Thread.current[:tenant_id]
    end
  end
end