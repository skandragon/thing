# == Schema Information
#
# Table name: instructables
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  approved                  :boolean          default(FALSE)
#  name                      :string(255)
#  material_limit            :integer
#  handout_limit             :integer
#  description_web           :text
#  handout_fee               :float
#  material_fee              :float
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  duration                  :float
#  culture                   :string(255)
#  topic                     :string(255)
#  subtopic                  :string(255)
#  description_book          :text
#  additional_instructors    :string(255)      is an Array
#  camp_name                 :string(255)
#  camp_address              :string(255)
#  camp_reason               :string(255)
#  adult_only                :boolean          default(FALSE)
#  adult_reason              :string(255)
#  fee_itemization           :text
#  requested_days            :date             is an Array
#  repeat_count              :integer          default(0)
#  scheduling_additional     :text
#  special_needs             :string(255)      is an Array
#  special_needs_description :text
#  heat_source               :boolean          default(FALSE)
#  heat_source_description   :text
#  requested_times           :string(255)      is an Array
#  track                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#  location_type             :string(255)      default("track")
#  proofread                 :boolean          default(FALSE)
#  proofread_by              :integer          default([]), is an Array
#  proofreader_comments      :text
#  year                      :integer
#  schedule                  :string(255)
#  info_tag                  :string(255)
#

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
      create_list(:instance, instructable.repeat_count, location: 'A&S 1', start_time: Instructable::CLASS_DATES[1], instructable_id: instructable.id)
    end
  end
end
