# == Schema Information
#
# Table name: instances
#
#  id                :integer          not null, primary key
#  instructable_id   :integer
#  start_time        :datetime
#  end_time          :datetime
#  location          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  override_location :boolean
#  year              :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance do
    start_time Instructable::CLASS_DATES[1]
    location 'MyString'
  end
end
