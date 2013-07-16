# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    instructables []
    published false
  end
end
