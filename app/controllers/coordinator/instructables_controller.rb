require 'csv'

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

    @instructables = @instructables.includes(:user, :instances).order('name')

    @instructables = @instructables.search_by_name(@search) if @search.present?

    #
    # if coordinator? filter only those they can see.  @track.blank? for
    # admin applies no filter, which is more efficient than listing
    # every possible track.
    #
    # If @track.present? ensure it is one that is allowed.
    #
    if admin? and @track == 'No Track'
      @instructables = @instructables.where("track IS NULL OR track=''")
    else
      tracks = current_user.filter_tracks(@track)
      @instructables = @instructables.where(track: tracks) unless tracks.nil?
    end

    @instructables = @instructables.where(approved: @approved) if @approved.present?
    @instructables = @instructables.where(scheduled: @scheduled) if @scheduled.present?
    @instructables = @instructables.where(topic: @topic) if @topic.present?

    respond_to do |format|
      format.html {
        @instructables = @instructables.paginate(page: params[:page], per_page: 20)
        session[:instructable_back] = request.fullpath
      }

      format.csv {
        filename = 'instructables.csv'

        column_names = %w(
          name track culture topic_and_subtopic
          adult_only duration repeat_count
        )
        csv_data = CSV.generate do |csv|
          names = %w(id scheduled?) + column_names
          csv << names
          @instructables.each do |instructable|
            data = [instructable.id, instructable.status_message ]
            data += instructable.attributes.values_at(*column_names)
            csv << data
          end
        end

        send_data(csv_data, type: Mime::CSV, disposition: "attachment", filename: filename)
      }
    end
  end
end
