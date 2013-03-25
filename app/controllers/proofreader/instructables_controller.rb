class Proofreader::InstructablesController < ApplicationController
  def index
    @allowed_tracks = Instructable::TRACKS.keys
    @track = params[:track]

    @proofread = params[:proofread]
    @topic = params[:topic]
    @search = params[:search]

    if params[:commit] == "Clear"
      @search = nil
      @track = nil
      @proofread = nil
      @topic = nil
    end

    @instructables = Instructable.includes(:user, :instances).order(:name)

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
    @instructable.is_proofreader = true
    if params['commit'] == 'Save and Mark Not Proofread'
      @instructable.proofread = false
    elsif params['commit'] == 'Save and Mark Proofread'
      @instructable.proofread = true
    end
    changelog = Changelog.build_changes('update', @instructable, current_user)
    if @instructable.update_attributes(permitted_params)
      @instructable.cleanup_unneeded_instances
      changelog.save # failure is an option...
      redirect_to session[:instructable_back] || proofreader_instructables_path, notice: "Class updated."
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
    allowed = Instructable::PROOFREADER_FIELDS
    params.require(:instructable).permit(*allowed)
  end
end
