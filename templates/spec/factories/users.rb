# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name)      {|n| "User #{'%05d' % n}"}
    sequence(:email)     {|n| "user#{"%05d" % n}@example.com"}

    account_type 'user'

    avatar_url  'http://google.com'
    profile_url 'http://google.com'

    tenant_id { Tenant.current_id }

    factory :admin_user do
      account_type 'admin'
    end
  end
end
