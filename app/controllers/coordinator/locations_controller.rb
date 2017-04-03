class Coordinator::LocationsController < ApplicationController
  include GriffinPdf

  def index
  end

  def freebusy
    @track = params[:track]
    if @track.blank?
      redirect_to coordinator_locations_path, notice: 'Select a track'
      return
    end

    unless current_user.allowed_tracks.include?(@track)
      redirect_to coordinator_locations_path, notice: 'Select a track you are coordinator for'
      return
    end

    @report = {}
    Instructable::CLASS_DATES.each do |date|
      @report[date] = Instance::free_busy_report_for(date, @track)
    end
  end


  def timesheets
    @date = params[:date]
    @track = params[:track]

    if @date.blank? or @track.blank?
      redirect_to coordinator_locations_path, notice: 'Select both a date and a track'
      return
    end

    unless Instructable::CLASS_DATES.include?(@date) and current_user.allowed_tracks.include?(@track)
      redirect_to coordinator_locations_path, notice: 'Select a valid date and track you are coordinator for'
      return
    end

    @locations = Instructable::TRACKS[@track]

    load_data

    if @instances.count == 0
      redirect_to coordinator_locations_path, notice: 'There are no instances of classes for that track on those days'
      return
    end

    filename = [
      'timesheets',
      Time.parse(@date).strftime('%Y-%m-%d'),
      @track.gsub(' ', '_').downcase,
    ].join('-') + '.pdf'
    cache_filename = filename
    render_pdf(filename, cache_filename)
  end

  private

  def all_days?
    @track == "Artisan's Row"
  end

  def render_pdf(filename, cache_filename = nil, user = nil)
    pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :landscape,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{Pennsic.year} Timesheet for #{@date}, track #{@track}",
        :Author => 'Pennsic University',
        :Subject => "Pennsic University #{Pennsic.year} Timesheet for #{@date}, track #{@track}",
        :Keywords => "pennsic university Timesheet #{@date} #{@track}",
        :Creator => 'Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/',
        :Producer => 'Pennsic Univeristy Class Maker',
        :CreationDate => Time.now,
    })

    pdf.font_families.update(
      'BodyFont' => {
        normal: Rails.root.join('app', 'assets', 'fonts', 'Arial.ttf'),
        bold: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold.ttf'),
        italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Italic.ttf'),
        bold_italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold Italic.ttf'),
      },
    )
    pdf.font 'BodyFont'


    header = [
      { content: 'When', background_color: 'ffffee' },
      { content: 'Title and Instructor', background_color: 'ffffee' },
      { content: 'Description', background_color: 'ffffee' }
    ]

    first_page = true
    last_selector = []
    items = []

    @instances.each { |instance|
      if all_days?
        current_selector = [instance.formatted_location]
      else
        current_selector = [instance.start_time.to_date, instance.formatted_location]
      end
      if last_selector != current_selector
        if items.size > 0
          pdf_render_table(pdf, items, header, 720, {0 => 90, })
          items = []
        end

        pdf.start_new_page unless first_page

        pdf.font_size 25

        if all_days?
          date_content = 'All Days'
        else
          date_content = instance.start_time.to_date.strftime('%A, %B %d, %Y')
        end
        pdf.text_box date_content, at: [0, pdf.bounds.top], width: 360, height: 25

        pdf.text_box instance.formatted_location,
                     align: :right,
                     at: [360, pdf.bounds.top], width: 360, height: 25

        pdf.font_size 10
        pdf.move_down 30
        if all_days?
          last_selector = [instance.formatted_location]
        else
          last_selector = [instance.start_time.to_date, instance.formatted_location]
        end
        first_page = false
      end

      times = []
      times << instance.start_time.strftime('%a, %b %d') if all_days?
      times << instance.start_time.strftime('%I:%M %p') + ' - ' + instance.end_time.strftime('%I:%M')
      times_content = times.join("\n")

      instructor_content = []
      instructor_content << markdown_html(instance.instructable.name)
      instructor_content << instance.instructable.user.titled_sca_name unless all_days?

      new_items = [
          {content: times_content},
          {inline_format: true, content: instructor_content.join("\n")},
          {inline_format: true, content: markdown_html(instance.instructable.description_book)}
      ]
      items << new_items
    }

    pdf_render_table(pdf, items, header, 720, { 0 => 90, })

    # set page footer
    options = {
      at: [pdf.bounds.left, 0],
      width: pdf.bounds.right,
      align: :center,
      start_count_at: 1,
      font_size: 10
    }

    now = Time.now.strftime('%A, %B %d, %H:%M %p')
    pdf.number_pages "Generated on #{now}", options

    data = pdf.render
    #cache_in_file(cache_filename, data)
    send_data(data, type: Mime[:pdf], disposition: "inline; filename=#{filename}", filename: filename)
  end

  def load_data
    @instances = Instance.where(location: @locations)
    if all_days?
      @instances = @instances.order(:location, :start_time)
    else
      @instances = @instances.for_date(@date)
    end
  end

end
