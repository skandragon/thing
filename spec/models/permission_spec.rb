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
  describe "as guest" do
    subject { Permission.new(nil) }

    it { should allow(:about, :anything) }

    it { should allow('devise/sessions', :anything) }
    it { should allow('devise/passwords', :anything) }
    it { should allow('devise/registrations', :anything) }

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

    it { should allow(:about, :anything) }

    it { should allow('devise/sessions', :anything) }
    it { should allow('devise/passwords', :anything) }
    it { should allow('devise/registrations', :anything) }

    it { should allow(:users, :edit, user) }
    it { should allow(:users, :show, user) }
    it { should_not allow(:users, :edit, other_user) }
    it { should_not allow(:users, :show, other_user) }

    it { should allow(:instructor_profiles, :new) }
    it { should allow(:instructor_profiles, :edit) }
    it { should_not allow(:instructor_profiles, :new, other_profile) }
    it { should_not allow(:instructor_profiles, :edit, other_profile) }

    it { should allow(:instructables, :new, instructable) }
    it { should allow(:instructables, :edit, instructable) }
    it { should_not allow(:instructables, :new, other_instructable) }
    it { should_not allow(:instructables, :edit, other_instructable) }

    it { should allow_param(:user, :name) }
    it { should_not allow_param(:user, :admin) }
  end

  describe "as coordinator" do
    let(:user) { FactoryGirl.build(:user, coordinator_tract: Instructable::TRACTS.keys.first) }
    subject { Permission.new(user) }

    it { should allow(:about, :anything) }

    it { should allow('devise/sessions', :anything) }
    it { should allow('devise/passwords', :anything) }
    it { should allow('devise/registrations', :anything) }
  end

  describe "as admin" do
    let (:user) { FactoryGirl.build(:user, admin: true) }
    let(:other_user) { FactoryGirl.create(:user) }
    subject { Permission.new(user) }

    it { should allow(:anything, :here) }
    it { should allow_param(:anything, :here) }
  end
end
