class Coordinator::LocationsController < ApplicationController
  include GriffinPdf

  PENNSIC_YEAR = 42

  def index
  end

  def freebusy
    @track = params[:track]
    if @track.blank?
      redirect_to coordinator_locations_path, notice: "Select a track"
      return
    end

    unless current_user.allowed_tracks.include?(@track)
      redirect_to coordinator_locations_path, notice: "Select a track you are coordinator for"
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
      redirect_to coordinator_locations_path, notice: "Select both a date and a track"
      return
    end

    unless Instructable::CLASS_DATES.include?(@date) and current_user.allowed_tracks.include?(@track)
      redirect_to coordinator_locations_path, notice: "Select a valid date and track you are coordinator for"
      return
    end

    load_data(@date)

    if @instances.count == 0
      redirect_to coordinator_locations_path, notice: "There are no instances of classes for that track on those days"
      return
    end

    filename = [
      'timesheets',
      Time.parse(@date).strftime('%Y-%m-%d'),
      @track.gsub(' ', '_').downcase,
    ].join("-") + '.pdf'
    cache_filename = filename
    render_pdf(filename, cache_filename)
  end

  private

  def render_pdf(filename, cache_filename = nil, user = nil)
    pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :landscape,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{PENNSIC_YEAR} Timesheet for #{@date}, track #{@track}",
        :Author => "Pennsic University",
        :Subject => "Pennsic University #{PENNSIC_YEAR} Timesheet for #{@date}, track #{@track}",
        :Keywords => "pennsic university Timesheet #{@date} #{@track}",
        :Creator => "Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/",
        :Producer => "Pennsic Univeristy Class Maker",
        :CreationDate => Time.now,
    })

    header = [
      { content: "When", background_color: 'ffffee' },
      { content: "Title and Instructor", background_color: 'ffffee' },
      { content: "Description", background_color: 'ffffee' }
    ]

    first_page = true
    last_selector = []
    items = []

    for instance in @instances
      if last_selector != [instance.start_time.to_date, instance.formatted_location]
        if items.size > 0
          pdf_render_table(pdf, items, header, 720, { 0 => 90, })
          items = []
        end

        pdf.start_new_page unless first_page

        pdf.font_size 25
          pdf.text_box instance.start_time.to_date.strftime("%A, %B %d, %Y"),
          at: [0, pdf.bounds.top], width: 360, height: 25
        pdf.text_box instance.formatted_location,
          align: :right,
          at: [360, pdf.bounds.top], width: 360, height: 25

        pdf.font_size 10
        pdf.move_down 30
        last_selector = [instance.start_time.to_date, instance.formatted_location]

        first_page = false
      end

      times = []
      times << instance.start_time.strftime("%I:%M %p") + " - " + instance.end_time.strftime("%I:%M")
      times_content = times.join("\n")

      new_items = [
        { content: times_content },
        { content: [ instance.instructable.name, instance.instructable.user.titled_sca_name ].join("\n") },
        { inline_format: true, content: markdown_html(instance.instructable.description_book) }
      ]
      items << new_items
    end

    pdf_render_table(pdf, items, header, 720, { 0 => 90, })

    # set page footer
    options = {
      at: [pdf.bounds.left, 0],
      width: pdf.bounds.right,
      align: :center,
      start_count_at: 1,
      font_size: 10
    }

    now = Time.now.strftime("%A, %B %d, %H:%M %p")
    pdf.number_pages "Generated on #{now}", options

    data = pdf.render
    #cache_in_file(cache_filename, data)
    send_data(data, type: Mime::PDF, disposition: "inline; filename=#{filename}", filename: filename)
  end

  def load_data(date)
    @instances = Instance.for_date(date)
  end

end
