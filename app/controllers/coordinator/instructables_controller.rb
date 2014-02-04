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

    @instructables = Instructable
    @instructables = @instructables.for_date(@date) if @date.present?

    @instructables = @instructables.includes(:user, :instances).order("name")

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

    puts @instructables.to_sql
  end
end
