# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "a#{n}" }
    sequence(:email) {|n| "email#{n}@example.com" }
    password "abcd1234"
    password_confirmation { |u| u.password }
  end
end
