class Permission
  def initialize(user)
    @allow_all = false
    @allowed_actions = {}
    @allowed_params = {}

    allow 'devise/sessions', :all
    allow 'devise/passwords', :all
    allow 'devise/registrations', :all
    allow :about, :all

    allow_param :user, [:name, :email, :password, :password_confirmation, :current_password]

    if user
      # All users can edit their own data
      allow :users, [:edit, :update, :show] do |record|
        record.id == user.id
      end

      allow :instructor_profiles, [:new, :edit, :create, :update] do |record|
        record.user_id == user.id
      end

      allow :instructables, :all do |record|
        record.user_id == user.id
      end
    end
    
    if user && user.admin?
      allow_all
    end

    if user && user.coordinator?
      allow :instructables, [:edit, :update] do |record|
        record.tract == user.coordinator_tract
      end
      allow_param :instructable, [:foo]
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
        @allowed_actions[[controller.to_s, action.to_s]] = block || true
      end
    end
  end

  def allow_param(resources, attributes)
    Array(resources).each do |resource|
      @allowed_params[resource.to_s] ||= []
      @allowed_params[resource.to_s] += Array(attributes).map(&:to_s)
    end
  end

  def allow_param?(resource, attribute)
    return true if @allow_all
    if @allowed_params[resource.to_s]
      return @allowed_params[resource.to_s].include?(attribute.to_s)
    end
    false
  end

  def allowed_params(resource)
    return @allowed_params[resource.to_s]
  end

  def permit_params!(params)
    if @allow_all
      params.permit!
    else
      @allowed_params.each do |resource, attributes|
        if params[resource].respond_to? :permit
          params[resource] = params[resource].permit(*attributes)
        end
      end
    end
  end
end
