# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name "Test"
    last_name  "User"
    sequence(:email) {|n| "user#{"%05d" % n}@example.com"}

    avatar_url  'http://google.com'
    profile_url 'http://google.com'

    association :tenant
  end
end
