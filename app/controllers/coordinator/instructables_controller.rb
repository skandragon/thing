require 'csv'

class Coordinator::InstructablesController < ApplicationController
  def index
    @allowed_tracks = current_user.allowed_tracks

    @approved = get_param(:approved)
    @date = get_param(:date)
    @scheduled = get_param(:scheduled)
    @schedule = get_param(:schedule)
    @track = get_param(:track)
    @topic = get_param(:topic)
    @search = params[:search]
    @checklater = get_param(:check_schedule_later)

    if params[:commit] == 'Clear'
      @approved = nil
      @schedule = nil
      @date = nil
      @scheduled = nil
      @track = nil
      @topic = nil
      @search = nil
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

    if @schedule == 'No Schedule'
      @instructables = @instructables.where("schedule IS NULL OR schedule=''")
    else
      @instructables = @instructables.where(schedule: @schedule) unless @schedule.nil?
    end

    @instructables = @instructables.where(approved: @approved) if @approved.present?
    @instructables = @instructables.where(scheduled: @scheduled) if @scheduled.present?
    @instructables = @instructables.where(topic: @topic) if @topic.present?
    @instructables = @instructables.where(check_schedule_later: @checklater) if @checklater.present?

    respond_to do |format|
      format.html {
        @instructables = @instructables.paginate(page: params[:page], per_page: 20)
        session[:instructable_back] = request.fullpath
      }

      format.csv {
        filename = 'instructables.csv'

        column_names = %w(
          name schedule track culture topic_and_subtopic
          adult_only duration repeat_count
        )
        csv_data = CSV.generate do |csv|
          names = %w(id) + column_names
          instance_names = %w(start_date start_time location)
          csv << names + instance_names
          @instructables.each do |instructable|
            data = [instructable.id]
            column_names.each do |column_name|
              data << instructable.send(column_name)
            end
            instances = instructable.instances
            instances.each do |instance|
              if instance.start_time.present?
                start_date = instance.start_time.strftime('%A, %B %e, %Y')
                start_time = instance.start_time.strftime('%I:%M %p')
              else
                start_date = ''
                start_time = ''
              end
              location = instance.formatted_location
              instance_data = [start_date, start_time, location]
              csv << data + instance_data
            end
          end
        end

        send_data(csv_data, type: Mime[:csv], disposition: "attachment", filename: filename)
      }
    end
  end

  private

  def get_param(field)
    ret = params[field]
    if ret =~ /^\(/
      ret = nil
    end
    ret
  end
end
