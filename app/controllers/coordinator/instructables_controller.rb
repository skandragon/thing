class Coordinator::InstructablesController < ApplicationController
  def index
    @allowed_tracks = current_user.allowed_tracks

    @approved = params[:approved]
    @date = params[:date]
    @scheduled = params[:scheduled]
    @search = params[:search]
    @track = params[:track]
    @topic = params[:topic]

    if params[:commit] == 'Clear'
      @approved = nil
      @date = nil
      @scheduled = nil
      @search = nil
      @track = nil
      @topic = nil
    end

    if @date.present?
      first_date = Time.zone.parse(@date).beginning_of_day
      last_date = Time.zone.parse(@date).end_of_day

      ids = Instance.where("start_time >= ? AND start_time <= ?", first_date, last_date).pluck(:instructable_id).uniq
      @instructables = Instructable.where(id: ids)
    else
      @instructables = Instructable
    end

    @instructables = @instructables.includes(:user, :instances).order(:name)

    @instructables = @instructables.search_by_name(@search) if @search.present?

    #
    # if coordinator? filter only those they can see.  @track.blank? for
    # admin applies no filter, which is more efficient than listing
    # every possible track.
    #
    # If @track.present? ensure it is one that is allowed.
    #
    if @track.blank? and coordinator?
      unless admin?
        @instructables = @instructables.where(track: @allowed_tracks)
      end
    else
      if admin? && @track == 'No Track'
        @instructables = @instructables.where("track IS NULL OR track=''")
      elsif coordinator_for?(@track)
        @instructables = @instructables.where(track: @track)
      else
        @instructables = @instructables.where(track: @allowed_tracks)
      end
    end

    @instructables = @instructables.where(approved: @approved) if @approved.present?
    @instructables = @instructables.where(scheduled: @scheduled) if @scheduled.present?
    @instructables = @instructables.where(topic: @topic) if @topic.present?

    @instructables = @instructables.paginate(page: params[:page], per_page: 20)

    session[:instructable_back] = request.fullpath
  end
end
