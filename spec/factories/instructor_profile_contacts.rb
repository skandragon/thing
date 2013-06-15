# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructor_profile_contact do
    protocol 'MyString'
    address 'MyString'
  end
end
