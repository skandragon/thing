class Coordinator::InstructablesController < ApplicationController
  def index
    if admin?
      @track = params[:track] || current_user.coordinator_track
    else
      @track = current_user.coordinator_track
    end
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

    @instructables = Instructable.order(:name)

    if @search.present?
      @instructables = @instructables.where('name ILIKE ?', "%#{@search.strip}%")
    end

    if @track.present?
      if @track == "No Track"
        @instructables = @instructables.where("track IS NULL OR track=''")
      else
        @instructables = @instructables.where(track: @track)
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
