# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    user_id 1
    instructables 1
    watch_topics "MyString"
    watch_cultures "MyString"
  end
end
