# encoding: utf-8

class Permission
  def initialize(user)
    @allow_all = false
    @allowed_actions = {}

    allow 'devise/sessions', :all
    allow 'sessions', :all
    allow 'users/passwords', :all
    allow 'users/registrations', :all
    allow :about, :all
    allow :calendars, :all
    allow :changelogs, :all
    allow :howto, :all
    allow :instructors, :all

    allow 'users/schedules', [ :show ] do |record|
      record.published? or record.token_access
    end

    allow 'users/schedules', [ :token ] do
      true
    end

    if user
      # All users can edit their own data
      allow :users, [:edit, :update, :show] do |record|
        record.id == user.id
      end

      allow :instructor_profiles, [ :new, :edit, :create, :update ] do |record|
        record.id == user.id
      end

      allow :instructables, [ :show, :new, :create, :edit, :update, :destroy ] do |record|
        record.user_id == user.id
      end

      allow 'users/schedules', [ :show ] do |record|
        record.user_id == user.id or record.published?
      end

      allow 'users/schedules', [ :new, :create, :edit, :update, :destroy ] do |record|
        record.user_id == user.id
      end
    end

    if user && user.admin?
      allow_all
    end

    if user && user.coordinator?
      allow :instructables, [:edit, :update] do |record|
        user.tracks.include?(record.track) || record.user_id == user.id
      end
      allow 'coordinator/instructables', :index
      allow 'coordinator/conflicts', :index
      allow 'coordinator/locations', :all
    end

    if user && user.proofreader?
      allow 'proofreader/instructables', :all do
        true
      end
    end
  end

  def allow?(controller, action, resource = nil)
    return true if @allow_all
    allowed = @allowed_actions[[controller.to_s, action.to_s]] || @allowed_actions[[controller.to_s, 'all']]
    if allowed && resource
      allowed = allowed.call(resource)
    end
    allowed
  end

  def allow_all
    @allow_all = true
  end

  def allow(controllers, actions, &block)
    Array(controllers).each do |controller|
      Array(actions).each do |action|
        #noinspection RubySimplifyBooleanInspection
        @allowed_actions[[controller.to_s, action.to_s]] = block || true
      end
    end
  end
end
