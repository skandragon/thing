# == Schema Information
#
# Table name: schedules
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  instructables :integer          default([]), is an Array
#  published     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  year          :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    instructables []
    published false
  end
end
