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

require 'rails_helper'

describe User do
  it 'generates an access token automatically' do
    u = FactoryGirl.create(:user)
    u.access_token.should_not be_nil
  end

  describe '#display_name' do
    it 'returns the email address if email is set but name is blank' do
      u = FactoryGirl.build(:user, mundane_name: nil, email: 'foo')
      u.display_name.should == 'foo'
    end

    it 'returns the name and email if both are set' do
      u = FactoryGirl.build(:user, mundane_name: 'foo', email: 'bar')
      u.display_name.should == 'foo (bar)'
    end

    it 'returns the name if set, but email is blank' do
      u = FactoryGirl.build(:user, mundane_name: 'foo', email: nil)
      u.display_name.should == 'foo'
    end
  end

  describe '#display_roles' do
    it 'no roles for no roles' do
      u = build(:user)
      u.display_roles.should == []
    end

    it 'admin if admin?' do
      u = build(:user, admin: true)
      u.display_roles.should include'Admin'
    end

    it 'instructor if instructor?' do
      u = build(:instructor)
      u.display_roles.should include'Instructor'
    end

    it 'coordinator if tracks' do
      u = build(:user, tracks: ['Middle Eastern'])
      u.display_roles.should include'Coordinator'
    end

    it 'proofreader if proofreader?' do
      u = build(:user, proofreader: true)
      u.display_roles.should include'Proofreader'
    end

    it 'PU Staff if pu_staff?' do
      u = build(:user, pu_staff: true)
      u.display_roles.should include'PU Staff'
    end

    it 'returns them all' do
      u = build(:instructor, admin: true, proofreader: true, pu_staff: true, tracks: ['Middle Eastern'])
      u.display_roles.should include'Admin'
      u.display_roles.should include'Instructor'
      u.display_roles.should include'Coordinator'
      u.display_roles.should include'Proofreader'
      u.display_roles.should include'PU Staff'
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
        create(:instructable, user_id: u.id, location_type: 'private-camp', camp_reason: 'This is the reason', camp_name: 'Foo')
      end
      create(:instructable, user_id: u.id, repeat_count: 2, location_type: 'merchant-booth', camp_reason: 'This is the reason', camp_name: 'Foo')
      u.instructables_session_count.should == 0
    end
  end

  describe '#filter_tracks' do
    it 'disallows a track if the user is not a coordinator at all' do
      u = create(:user)
      u.filter_tracks('Pennsic University').should == []
    end

    it 'allows a track if the user is a coordinator for it' do
      u = create(:user, tracks: ['Pennsic University'])
      u.filter_tracks('Pennsic University').should == ['Pennsic University']
    end

    it 'disallows a track if the user is not a coordinator for it' do
      u = create(:user, tracks: ['Performing Arts and Music'])
      u.filter_tracks('Pennsic University').should == []
    end

    it 'allows a track if user is admin' do
      u = create(:user, tracks: ['Pennsic University'], admin: true)
      u.filter_tracks('Pennsic University').should == ['Pennsic University']
    end

    it 'returns the allowed tracks when the input list is empty and not admin' do
      u = create(:user, tracks: ['Pennsic University'])
      u.filter_tracks(nil).should == ['Pennsic University']
    end

    it 'returns nil when given an empty list and admin' do
      u = create(:user, tracks: ['Pennsic University'], admin: true)
      u.filter_tracks(nil).should be_nil
    end

  end
end
