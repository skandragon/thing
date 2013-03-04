class Coordinator::InstructablesController < ApplicationController
  def index
    @allowed_tracks = current_user.allowed_tracks
    @track = params[:track]

    @approved = params[:approved]
    @scheduled = params[:scheduled]
    @topic = params[:topic]
    @search = params[:search]

    if params[:commit] == "Clear"
      @search = nil
      @track = nil
      @approved = nil
      @scheduled = nil
      @topic = nil
    end

    @instructables = Instructable.includes(:user, :instances).order(:name)

    if @search.present?
      @instructables = @instructables.where('name ILIKE ?', "%#{@search.strip}%")
    end

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
      if admin? && @track == "No Track"
        @instructables = @instructables.where("track IS NULL OR track=''")
      elsif coordinator_for?(@track)
        @instructables = @instructables.where(track: @track)
      else
        @instructables = @instructables.where(track: @allowed_tracks)
      end
    end

    if @approved.present?
      @instructables = @instructables.where(approved: @approved)
    end

    if @scheduled.present?
      @instructables = @instructables.where(scheduled: @scheduled)
    end

    if @topic.present?
      @instructables = @instructables.where(topic: @topic)
    end

    @instructables = @instructables.paginate(page: params[:page], per_page: 20)

    session[:instructable_back] = request.fullpath
  end
end
