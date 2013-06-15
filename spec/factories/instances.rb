# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance do
    start_time Instructable::CLASS_DATES[1]
    location 'MyString'
  end
end
