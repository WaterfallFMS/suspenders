class Tenant < ActiveRecord::Base
  validates :uuid, :presence => true, :uniqueness => true
  validates :name, :presence => true, :uniqueness => true

  has_many :users

  def self.find_or_create_from_saml(account_hash)
    values = JSON.parse(account_hash)

    found = where(:uuid => values['uuid']).first
    found ||= Tenant.new :uuid => values['uuid']
    found.name = values['name']
    found.save!
    found
  end
end
