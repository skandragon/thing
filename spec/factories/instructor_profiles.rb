# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructor_profile do
    sca_name 'Bob the Butcher'
    sca_title 'lord'
    kingdom 'ansteorra'
    phone_number '+1 405.555.1212'
    mundane_name 'Bob Smith'
  end
end
