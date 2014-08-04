require 'rails_helper'

RSpec::Matchers.define :permit do |*args|
  match do |permission|
    permission.allow?(*args).should be_true
  end
end

describe Permission do
  describe 'as guest' do
    subject { Permission.new(nil) }

    it { should permit(:about, :anything) }

    it { should permit('devise/sessions', :anything) }
    it { should permit('devise/passwords', :anything) }
    it { should permit('devise/registrations', :anything) }

    it { should permit('users/schedules', :token) }

    it { should_not permit('admin/users', :show) }
    it { should_not permit(:users, :show) }
  end

  describe 'as user' do
    let(:user) { create(:instructor) }
    let(:instructable) { create(:instructable, user_id: user.id) }

    let(:other_user) { create(:instructor) }
    let(:other_instructable) { create(:instructable, user_id: other_user.id) }

    subject { Permission.new(user) }

    it {
      should permit(:about, :anything)
    }

    it {
      should permit('devise/sessions', :anything)
      should permit('devise/passwords', :anything)
      should permit('devise/registrations', :anything)
    }

    it {
      should permit(:users, :edit, user)
      should permit(:users, :show, user)
      should_not permit(:users, :edit, other_user)
      should_not permit(:users, :show, other_user)
    }

    it {
      should permit(:instructables, :new, instructable)
      should permit(:instructables, :edit, instructable)
      should_not permit(:instructables, :new, other_instructable)
      should_not permit(:instructables, :edit, other_instructable)
      should_not permit(:proofreader, :edit)
    }
  end

  #
  # Proofreaders can edit any instructable, but only with limited
  # fields.
  #
  describe 'as proofreader' do
    let(:user) { create(:proofreader) }

    subject { Permission.new(user) }

    it {
      should permit('proofreader/instructables', :index)
      should permit('proofreader/instructables', :edit)
      should permit('proofreader/instructables', :update)
    }
  end

  describe 'as coordinator' do
    let(:track) { Instructable::TRACKS.keys.first }
    let(:other_track) { Instructable::TRACKS.keys.last }

    let(:user) { create(:instructor, tracks: [track]) }
    let(:instructable) { build(:instructable, user_id: user.id) }

    let(:other_user) { create(:instructor) }
    let(:other_track_instructable) { build(:instructable, user_id: other_user.id, track: track) }
    let(:other_nontrack_instructable) { build(:instructable, user_id: other_user.id, track: other_track) }

    subject { Permission.new(user) }

    it {
      should permit(:instructables, :edit, instructable)
      should permit(:instructables, :edit, other_track_instructable)
      should permit('coordinator/conflicts', :index)
      should permit('coordinator/locations', :anything)
      should_not permit(:instructables, :edit, other_nontrack_instructable)
      should_not permit(:proofreader, :edit)
    }
  end

  describe 'as admin' do
    let(:user) { build(:user, admin: true) }
    let(:other_user) { create(:user) }
    subject { Permission.new(user) }

    it { should permit(:anything, :here) }
  end
end
