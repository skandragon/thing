class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize

  delegate :allow?, to: :current_permission
  helper_method :allow?

  delegate :allow_param?, to: :current_permission
  helper_method :allow_param?

  helper_method :admin?
  helper_method :instructor?

  private

  def instructor?
    current_user && current_user.instructor?
  end

  def admin?
    current_user && current_user.admin?
  end

  def current_permission
    @current_permission ||= Permission.new(current_user)
  end

  def current_resource
    nil
  end

  def authorize
    controller = params[:controller]
    action = params[:action]
    if current_permission.allow?(controller, action, current_resource)
      current_permission.permit_params! params
    else
      message = 'Not authorized.'
      if ['development', 'test'].include?Rails.env
        message += " (controller: #{controller}, action: #{action}"
        if current_resource
          message += ", resource: #{current_resource.class} #{current_resource.id}"
        end
        message += ')'
      end
      redirect_to root_url, alert: message
    end
  end

  def authorize_user
    @target_user ||= User.find(params[:user_id])
    @target_user.id == current_user.id or current_user.admin?
  end

end
