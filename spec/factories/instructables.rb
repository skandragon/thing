# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructable do
    name 'MyString'
    description_book 'Book Description Goes Here.'
    repeat_count 1
    duration 1
    topic Instructable::TOPICS.keys.first
    location_type 'track'
    is_proofreader { |u| u.proofread? }
  end

  factory :scheduled_instructable, parent: :instructable do
    after(:create) do |instructable, evaluator|
      create_list(:instance, evaluator.repeat_count, instructable: instructable)
    end
  end
end
