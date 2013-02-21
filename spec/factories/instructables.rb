# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructable do
    name 'MyString'
    description_book 'Book Description Goes Here.'
    repeat_count 1
    duration 1
    topic Instructable::TOPICS.keys.first
  end
end
