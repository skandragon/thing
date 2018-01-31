class Users::SchedulesController < ApplicationController
  before_action :load_user

  def show
    # TODO: need to handle format here, and return an empty schedule for ISC requests
    # where the user does exist, 404 where it does not, and redirect for html requests.

    unless @user
      raise ActiveRecord::RecordNotFound.new('Not Found')
    end

    render_options = { user: @user }

    uncached = params[:uncached_for_tests].present?

    respond_to do |format|
      format.html {
        if @user.schedule.nil? or @user.schedule.instructables.count == 0
          if current_user and current_user.id == @user.id
            redirect_to edit_user_schedule_path(@user) and return
          else
            redirect_to root_path, alert: 'No such schedule' and return
          end
        end
        @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)').includes(instructable: [:user])
      }

      format.ics {
        if @user.schedule.nil? or @user.schedule.instructables.count == 0
          raise ActiveRecord::RecordNotFound.new('Not Found')
        end
        @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)').includes(instructable: [:user])

        filename = "pennsic-#{Pennsic.year}-user#{@user.id}.ics"
        cache_filename = Rails.root.join('tmp', filename)

        if File.exist?(cache_filename)
          File.unlink(cache_filename)
        end

        render_options[:calendar_name] = "PennsicU #{Pennsic.year}"
        renderer = CalendarRenderer.new(@instances, @instructables)
        data = renderer.render_ics(render_options, filename, cache_filename)
        cache_in_file(cache_filename, data)
        send_file(cache_filename, type: Mime[:ics], disposition: "inline; filename=#{filename}", filename: filename)
#        File.unlink(cache_filename) if uncached
      }

      format.pdf {
        if @user.schedule.nil? or @user.schedule.instructables.count == 0
          raise ActiveRecord::RecordNotFound.new('Not Found')
        end

        @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)').includes(instructable: [:user])
        omit_descriptions = params[:brief].present?

        @instructables = Instructable.where(id: @instances.map(&:instructable_id))

        filename = [
          "pennsic-#{Pennsic.year}-#{@user.id}",
          omit_descriptions ? 'brief' : nil,
        ].compact.join('-') + '.pdf'
        cache_filename = Rails.root.join('tmp', filename)

        if File.exist?(cache_filename)
          File.unlink(cache_filename)
        end

        render_options[:omit_descriptions] = omit_descriptions
        render_options[:no_long_descriptions] = true
        renderer = CalendarRenderer.new(@instances, @instructables)
        data = renderer.render_pdf(render_options, filename)
        cache_in_file(cache_filename, data)
        send_file(cache_filename, type: Mime[:pdf], disposition: "inline; filename=#{filename}", filename: filename)
#        File.unlink(cache_filename) if uncached
      }

      format.csv {
        if @user.schedule.nil? or @user.schedule.instructables.count == 0
          raise ActiveRecord::RecordNotFound.new('Not Found')
        end

        @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)').includes(instructable: [:user])
        filename = "pennsic-#{Pennsic.year}-user#{@user.id}.csv"
        cache_filename = Rails.root.join('tmp', filename)

        if File.exist?(cache_filename)
          File.unlink(cache_filename)
        end

        renderer = CalendarRenderer.new(@instances, @instructables)
        data = renderer.render_csv(render_options, "pennsic-#{Pennsic.year}-user#{@user.id}.csv")
        cache_in_file(cache_filename, data)
        send_file(cache_filename, type: Mime[:csv], disposition: "filename=#{filename}", filename: filename)
      }

      format.xlsx {
        if @user.schedule.nil? or @user.schedule.instructables.count == 0
          raise ActiveRecord::RecordNotFound.new('Not Found')
        end

        @instances = Instance.where(instructable_id: @user.schedule.instructables).order('start_time, btrsort(location)').includes(instructable: [:user])
        filename = "pennsic-#{Pennsic.year}-#{@user.id}.xlsx"
        cache_filename = Rails.root.join('tmp', filename)

        if File.exist?(cache_filename)
          File.unlink(cache_filename)
        end

        renderer = CalendarRenderer.new(@instances, @instructables)
        data = renderer.render_xlsx(render_options, "pennsic-#{Pennsic.year}-user#{@user.id}.xlsx")
        cache_in_file(cache_filename, data)
        send_file(cache_filename, type: Mime[:xlsx], disposition: "filename=#{filename}", filename: filename)
#        File.unlink(cache_filename) if uncached
      }

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
    user_id = params[:user_id]
    if user_id =~ /^[a-zA-Z]+/
      @user ||= User.where(access_token: user_id).first
      if @user and @user.schedule
        @user.schedule.token_access = true
      end
    else
      @user ||= User.where(id: user_id).first
    end
    @user
  end

  def cache_in_file(cache_filename, data)
    if cache_filename
      tmp_filename = [cache_filename, SecureRandom.hex(16)].join
      File.open(tmp_filename, 'wb') do |f|
        f.write data
      end
      File.rename(tmp_filename, cache_filename)
    end
  end

  def current_resource
    if load_user
      @user.schedule
    else
      Schedule.new(published: false)
    end
  end

end
