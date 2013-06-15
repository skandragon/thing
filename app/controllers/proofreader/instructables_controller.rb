class Proofreader::InstructablesController < ApplicationController
  def index
    @allowed_tracks = Instructable::TRACKS.keys
    @track = params[:track]

    @proofread = params[:proofread]
    @topic = params[:topic]
    @search = params[:search]

    if params[:commit] == 'Clear'
      @search = nil
      @track = nil
      @proofread = nil
      @topic = nil
    end

    @instructables = Instructable.includes(:user, :instances).order(:name)

    if @search.present?
      @instructables = @instructables.where('name ILIKE ? OR description_web ILIKE ? or description_book ILIKE ?', "%#{@search.strip}%", "%#{@search.strip}%", "%#{@search.strip}%")
    end

    if @track.present?
      if @track == 'No Track'
        @instructables = @instructables.where("track IS NULL OR track=''")
      else
        @instructables = @instructables.where(track: @track)
      end
    end

    if @proofread.present?
      @instructables = @instructables.where(proofread: @proofread)
    end

    if @topic.present?
      @instructables = @instructables.where(topic: @topic)
    end

    @instructables = @instructables.paginate(page: params[:page], per_page: 20)

    session[:instructable_back] = request.fullpath
  end

  def edit
    @instructable = Instructable.find params[:id]
  end

  def update
    if params['commit'] == 'Save and Mark Not Proofread'
      @instructable.proofread_by = @instructable.proofread_by - [current_user.id]
      @instructable.proofread = @instructable.proofread_by.size >= 2
    elsif params['commit'] == 'Save and Mark Proofread'
      @instructable.is_proofreader = current_user.id
    end

    preflight = Changelog.build_attributes(@instructable)
    @instructable.assign_attributes(permitted_params)
    @instructable.adjust_instances
    changelog = Changelog.build_changes('update', @instructable, current_user)
    if @instructable.save
      @instructable.cleanup_unneeded_instances
      changelog.validate_and_save # failure is an option...
      redirect_to session[:instructable_back] || proofreader_instructables_path, notice: 'Class updated.'
    else
      render action: :edit
    end
  end

  private

  def current_resource
    if params[:id].present?
      @instructable ||= Instructable.find(params[:id])
    end
    @instructable
  end

  def permitted_params
    allowed = Instructable::PROOFREADER_FIELDS + [ :proofreader_comments ]
    params.require(:instructable).permit(*allowed)
  end
end
