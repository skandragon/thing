class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize
  before_filter :miniprofiler

  delegate :allow?, to: :current_permission
  helper_method :allow?

  helper_method :admin?
  helper_method :instructor?
  helper_method :coordinator?
  helper_method :coordinator_for?
  helper_method :proofreader?
  helper_method :markdown_html

  private

  def helpers
    @helper ||= Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end

  def markdown_html(text)
    return '' if text.blank?

    @markdown_renderer ||= Redcarpet::Render::XHTML.new(
      :filter_html => true,
      :no_images => true,
      :no_links => true,
      :no_styles => true)
    @markdown ||= Redcarpet::Markdown.new(@markdown_renderer,
                               :no_intra_emphasis => true,
                               :strikethrough => true,
                               :superscript => true)
    @coder ||= HTMLEntities.new
    helpers.sanitize @coder.decode(@markdown.render(text)), tags: %w(strong em sup del)
  end

  def miniprofiler
    if current_user && admin? && current_user.email == 'explorer@flame.org'
      Rack::MiniProfiler.authorize_request
    end
  end

  def instructor?
    current_user && current_user.instructor?
  end

  def admin?
    current_user && current_user.admin?
  end

  def coordinator?
    admin? or (current_user && current_user.tracks.count > 0)
  end

  def coordinator_for?(track)
    admin? or (coordinator? and current_user.tracks.include?track)
  end

  def proofreader?
    admin? or (current_user && current_user.proofreader?)
  end

  def current_permission
    @current_permission ||= Permission.new(current_user)
  end

  def current_resource
    nil
  end

  def authorization_failure_message(controller, action, current_resource)
    message = 'Not authorized.'
    if ['development', 'test'].include?Rails.env
      message += " (controller: #{controller}, action: #{action}"
      if current_resource
        message += ", resource: #{current_resource.class} #{current_resource.id}"
      end
      message += ')'
    end
    message
  end

  def authorize
    controller = params[:controller]
    action = params[:action]
    unless current_permission.allow?(controller, action, current_resource)
      message = authorization_failure_message(controller, action, current_resource)
      redirect_to root_url, alert: message
    end
  end

  def authorize_user
    unless current_user
      redirect_to root_url, alert: "You must log in." and return false
    end
    @target_user ||= User.find(params[:user_id])
    @target_user.id == current_user.id or current_user.admin?
  end

end
