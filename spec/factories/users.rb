# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) {|n| "email#{n}@example.com" }

  factory :user do
    phone_number '+1 405.555.1212'
    mundane_name 'Bob Smith'
    email { generate :email }
    password 'abcd1234'
    password_confirmation { |u| u.password }
  end

  factory :instructor, parent: :user do
    instructor true
    sequence(:sca_name) { |n| "rothgar#{n}" }
    sca_title 'lord'
    kingdom 'ansteorra'
    class_limit 4
  end

  factory :proofreader, parent: :user do
    proofreader true
  end
end
