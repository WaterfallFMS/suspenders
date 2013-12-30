class Tenant < ActiveRecord::Base
  include TenantContainer

  has_many :users
  has_many :forums

  validates :uuid, :presence => true, :uniqueness => true
  validates :name, :presence => true

  def self.find_or_create_from_saml(account_hash)
    values = JSON.parse(account_hash)

    found = where(:uuid => values['uuid']).first
    found ||= Tenant.new :uuid => values['uuid']
    found.name = values['name']
    found.save!

    self.current_id = found.id

    found
  end
end
