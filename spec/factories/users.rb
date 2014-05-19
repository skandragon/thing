# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  mundane_name           :string(255)
#  access_token           :string(255)
#  admin                  :boolean          default(FALSE)
#  pu_staff               :boolean
#  tracks                 :string(255)      default([]), is an Array
#  sca_name               :string(255)
#  sca_title              :string(255)
#  phone_number           :string(255)
#  class_limit            :integer
#  kingdom                :string(255)
#  phone_number_onsite    :string(255)
#  contact_via            :text
#  no_contact             :boolean          default(FALSE)
#  available_days         :date             is an Array
#  instructor             :boolean          default(FALSE)
#  proofreader            :boolean          default(FALSE)
#  profile_updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) {|n| "email#{n}@example.com" }

  factory :user do
    phone_number '+1 405.555.1212'
    mundane_name 'Bob Smith'
    email { generate :email }
    password 'abcd1234'
    password_confirmation { |u| u.password }
  end

  factory :instructor, parent: :user do
    instructor true
    sequence(:sca_name) { |n| "rothgar#{n}" }
    sca_title 'lord'
    kingdom 'ansteorra'
    class_limit 4
  end

  factory :proofreader, parent: :user do
    proofreader true
  end
end
