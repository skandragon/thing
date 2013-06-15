class Users::SchedulesController < ApplicationController
  before_filter :load_user

  def show
    if @user.schedule.nil? or @user.schedule.instructables.count == 0
      if current_user.id == @user.id
        redirect_to edit_user_schedule_path(@user)
      else
        redirect_to root_path, alert: 'No such schedule'
      end
    else
      @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)')
    end
  end

  def edit
    @schedule = @user.schedule
    @schedule ||= @user.create_schedule

    instructable_search
  end

  def update
    respond_to do |format|
      format.json {
        if params.has_key?(:published)
          @user.schedule.published = params[:published]
        end
        if params.has_key?(:add_instructable)
          @user.schedule.instructables = (@user.schedule.instructables + [params[:add_instructable].to_i]).uniq.sort
        end
        if params.has_key?(:remove_instructable)
          @user.schedule.instructables = (@user.schedule.instructables - [params[:remove_instructable].to_i]).sort
        end
        if @user.schedule.save
          render json: {}
        else
          render json: {}, status: :unprocessable_entity
        end
      }
    end
  end

  private

  def instructable_search
    @topic = params[:topic]
    @culture = params[:culture]
    @search = params[:search]

    if params[:commit] == 'Clear'
      @search = nil
      @topic = nil
      @culture = nil
    end

    @instructables = Instructable.includes(:instances).order(:name).where(scheduled: true)

    if @search.present?
      @instructables = @instructables.where('name ILIKE ?', "%#{@search.strip}%")
    end

    if @topic.present?
      @instructables = @instructables.where(topic: @topic)
    end

    if @culture.present?
      @instructables = @instructables.where(culture: @culture)
    end

    @instructables = @instructables.paginate(page: params[:page], per_page: 20)
  end

  def load_user
    @user ||= User.where(id: params[:user_id]).first
    if @user.nil?
      redirect_to root_path, alert: 'No such schedule' and return false
    end
    true
  end
end
