# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tenant do
    uuid {UUID.generate}
    name 'Demo Tenant'
  end
end
