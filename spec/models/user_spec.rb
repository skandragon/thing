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
#  name                   :string(255)
#  access_token           :string(255)
#  admin                  :boolean          default(FALSE)
#  coordinator_track      :string(255)
#  pu_staff               :boolean
#

require 'spec_helper'

describe User do
  it "generates an access token automatically" do
    u = FactoryGirl.create(:user)
    u.access_token.should_not be_nil
  end

  describe '#display_name' do
    it "returns the email address if email is set but name is blank" do
      u = FactoryGirl.build(:user, name: nil, email: "foo")
      u.display_name.should == "foo"
    end

    it "returns the name and email if both are set" do
      u = FactoryGirl.build(:user, name: "foo", email: "bar")
      u.display_name.should == "foo (bar)"
    end

    it "returns the name if set, but email is blank" do
      u = FactoryGirl.build(:user, name: "foo", email: nil)
      u.display_name.should == "foo"
    end
  end

  describe '#instructables_session_count' do
    it 'returns 0 if no instructables' do
      u = create(:user)
      u.instructables_session_count.should == 0
    end

    it 'returns 4 for three PU-space classes with various repeat counts' do
      u = create(:user)
      2.times do
        create(:instructable, user_id: u.id)
      end
      create(:instructable, user_id: u.id, repeat_count: 2)
      u.instructables_session_count.should == 4
    end

    it 'returns 4 for three non-PU-space classes with various repeat counts' do
      u = create(:user)
      2.times do
        create(:instructable, user_id: u.id, location_camp: true, camp_reason: 'This is the reason', camp_name: "Foo")
      end
      create(:instructable, user_id: u.id, repeat_count: 2, location_camp: true, camp_reason: 'This is the reason', camp_name: 'Foo')
      u.instructables_session_count.should == 0
    end
  end
end
