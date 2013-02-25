class Coordinator::InstructablesController < ApplicationController
  def index
    if current_user.admin?
      @tract = params[:tract]
    end
    @tract ||= current_user.coordinator_tract
    @approved = params[:approved]
    @scheduled = params[:scheduled]
    @topic = params[:topic]
    @search = params[:search]
    
    if params[:commit] == "Clear"
      @search = nil
      @tract = nil
      @approved = nil
      @scheduled = nil
      @topic = nil
    end

    @instructables = Instructable.order(:name)
    
    if @search.present?
      @instructables = @instructables.where('name ILIKE ?', "%#{@search.strip}%")
    end

    if @tract.present?
      @instructables = @instructables.where(tract: @tract)
    end

    if @approved.present?
      @instructables = @instructables.where(approved: @approved)
    end

    if @scheduled.present?
      @scheduled = @scheduled.to_i
      if @scheduled == 1
        @instructables = @instructables.where('start_time IS NOT NULL')
      elsif @scheduled == 0
        @instructables = @instructables.where('start_time IS NULL')
      end
    end

    if @topic.present?
      @instructables = @instructables.where(topic: @topic)
    end

    @instructables = @instructables.paginate(page: params[:page], per_page: 20)
  end
end
