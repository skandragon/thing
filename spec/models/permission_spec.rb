require 'spec_helper'

RSpec::Matchers.define :allow do |*args|
  match do |permission|
    permission.allow?(*args).should be_true
  end
end

RSpec::Matchers.define :allow_param do |*args|
  match do |permission|
    permission.allow_param?(*args).should be_true
  end
end

describe Permission do
  describe "setup" do
    let(:permission) { Permission.new(nil) }

    it "should use model columns if model name is provided to allow params" do
      permission.allow_param?(:instructor_profile_contact, :protocol).should_not be_true
      permission.allow_param(:instructor_profile_contact, InstructorProfileContact)
      permission.allow_param?(:instructor_profile_contact, :protocol).should be_true
      permission.allowed_params(:instructor_profile_contact).should == InstructorProfileContact.column_names
    end
  end

  describe "as guest" do
    subject { Permission.new(nil) }

    it { should allow(:about, :anything) }

    it { should allow('devise/sessions', :anything) }
    it { should allow('users/passwords', :anything) }
    it { should allow('users/registrations', :anything) }

    it { should_not allow('admin/users', :show) }
    it { should_not allow(:users, :show) }
  end

  describe "as user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { create(:instructor_profile, user_id: user.id) }
    let(:instructable) { create(:instructable, user_id: user.id) }

    let(:other_user) { FactoryGirl.create(:user) }
    let(:other_profile) { create(:instructor_profile, user_id: other_user.id) }
    let(:other_instructable) { create(:instructable, user_id: other_user.id) }

    subject { Permission.new(user) }

    it {
      should allow(:about, :anything)
    }

    it {
      should allow('devise/sessions', :anything)
      should allow('users/passwords', :anything)
      should allow('users/registrations', :anything)
    }

    it {
      should allow(:users, :edit, user)
      should allow(:users, :show, user)
      should_not allow(:users, :edit, other_user)
      should_not allow(:users, :show, other_user)
    }

    it {
      should allow(:instructor_profiles, :new)
      should allow(:instructor_profiles, :edit)
      should_not allow(:instructor_profiles, :new, other_profile)
      should_not allow(:instructor_profiles, :edit, other_profile)
    }

    it {
      should allow(:instructables, :new, instructable)
      should allow(:instructables, :edit, instructable)
      should_not allow(:instructables, :new, other_instructable)
      should_not allow(:instructables, :edit, other_instructable)
    }

    it { should allow_param(:user, :name) }
    it { should_not allow_param(:user, :admin) }
  end

  describe "as coordinator" do
    let(:tract) { Instructable::TRACTS.keys.first }
    let(:other_tract) { Instructable::TRACTS.keys.last }

    let(:user) { FactoryGirl.create(:user, coordinator_tract: tract) }
    let(:profile) { build(:instructor_profile, user_id: user.id) }
    let(:instructable) { build(:instructable, user_id: user.id) }

    let(:other_user) { FactoryGirl.create(:user) }
    let(:other_tract_instructable) { build(:instructable, user_id: other_user.id, tract: tract) }
    let(:other_nontract_instructable) { build(:instructable, user_id: other_user.id, tract: other_tract) }

    subject { Permission.new(user) }

    it {
      should allow(:instructables, :edit, instructable)
      should allow(:instructables, :edit, other_tract_instructable)
      should_not allow(:instructables, :edit, other_nontract_instructable)
    }
  end

  describe "as admin" do
    let(:user) { FactoryGirl.build(:user, admin: true) }
    let(:other_user) { FactoryGirl.create(:user) }
    subject { Permission.new(user) }

    it { should allow(:anything, :here) }
    it { should allow_param(:anything, :here) }
  end
end
