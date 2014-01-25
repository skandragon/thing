# == Schema Information
#
# Table name: instructor_profile_contacts
#
#  id         :integer          not null, primary key
#  protocol   :string(255)
#  address    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructor_profile_contact do
    protocol 'MyString'
    address 'MyString'
  end
end
