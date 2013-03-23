class CalendarsController < ApplicationController
  PENNSIC_YEAR = 42

  def index
    respond_to do |format|
      format.html
      format.ics {
        filename = "pennsic-#{PENNSIC_YEAR}-all.ics"

        @events = PennsicEvent.where("start_time IS NOT NULL")
        @calendar_name = "PennsicU #{PENNSIC_YEAR}"

        cache_filename = Rails.root.join("tmp", filename)
        if File.exists?(cache_filename)
          send_file(cache_filename, type: Mime::ICS, disposition: "inline; filename=#{filename}", filename: filename)
        else
          render_calendar(filename, cache_filename)
        end
      }
      format.pdf {
        @omit_descriptions = params[:brief].present?

        if @omit_descriptions
          filename = "pennsic-#{PENNSIC_YEAR}-all-brief.pdf"
        else
          filename = "pennsic-#{PENNSIC_YEAR}-all.pdf"
        end

        cache_filename = Rails.root.join("tmp", filename)
        if File.exists?(cache_filename)
          send_file(cache_filename, type: Mime::PDF, disposition: "inline; filename=#{filename}", filename: filename)
        else
          load_data
          render_pdf(filename, cache_filename)
        end
      }
      format.csv {
        @events = PennsicEvent.order(:start_time, :title)

        render_csv("pennsic-#{PENNSIC_YEAR}-full.csv")
      }
      format.xlsx {
        @dates = PennsicEvent.get_dates
        @formatted_dates = {}

        for date in @dates
          @formatted_dates[date] = Time.parse(date).strftime("%A, %B %e").gsub(/\ +/, " ")
        end

        @events = {}
        for date in @dates
          @events[date] = PennsicEvent.for_date(date).order(:start_time, :title)
        end
        @events[nil] = PennsicEvent.for_date(nil).order(:start_time, :title)
        if @events[nil].count > 0
          @dates << nil
          @formatted_dates[nil] = "No Date"
        end

        render_xlsx("pennsic-#{PENNSIC_YEAR}-full.xlsx")
      }
    end
  end

  private

  def make_uid(*items)
    items << @cal_id or "all"
    d = Digest::SHA1.new
    d << items.join("/")
    d.hexdigest + "@pennsic.flame.org"
  end

  def date_format(d)
    d.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def render_calendar(filename, cache_filename = nil)
    now = Time.now.utc

    calendar = RiCal.Calendar do |cal|
      cal.prodid = "//flame.org//PennsicU Converter.0//EN"
      cal.add_x_property("X-WR-CALNAME", @calendar_name)
      cal.add_x_property("X-WR-RELCALID", make_uid(@calendar_name)) # should be static per calendar
      cal.add_x_property("X-WR-CALDESC", "PennsicU #{PENNSIC_YEAR} Class Schedule")
      cal.add_x_property("X-PUBLISHED-TTL", "3600")

      for item in @events
        cal.event do |event|
          prefix = []
          prefix << "Subject: #{item.subject}" if item.subject
          prefix << "Secondary Subject: #{item.subject2}" if item.subject2
          prefix << "Instructor: #{item.instructor_titled}" if item.instructor_titled
          prefix << "Additional Instructors: #{item.additional_instructors}" if item.additional_instructors
          prefix << "Class limit: #{item.class_limit}" if item.class_limit
          prefix << "Handout limit: #{item.handout_limit}" if item.handout_limit

          event.dtstamp = date_format(now)
          event.dtstart = date_format(item.start_time)
          event.dtend = date_format(item.finish_time)
          event.summary = item.title
          event.description = [ prefix.join("\n"), "", item.description ].join("\n")
          event.location = item.location
          event.uid = make_uid(item)
          event.transp = "OPAQUE"
          event.status = "CONFIRMED"
          event.sequence = item.updated_at.to_i
        end
      end
    end

    data = calendar.to_s.gsub("::", ":")
    cache_in_file(cache_filename, data)
    send_data(data, type: Mime::ICS, disposition: "inline; filename=#{filename}", filename: filename)
  end

  BOX_MARGIN   = 24

  # Additional indentation to keep the line measure with a reasonable size
  #
  INNER_MARGIN = 30

  # Vertical Rhythm settings
  #
  RHYTHM  = 10
  LEADING = 2

  # Colors
  #
  BLACK      = "000000"
  LIGHT_GRAY = "F2F2F2"
  GRAY       = "DDDDDD"
  DARK_GRAY  = "333333"
  BROWN      = "A4441C"
  ORANGE     = "F28157"
  LIGHT_GOLD = "FBFBBE"
  DARK_GOLD  = "EBE389"
  BLUE       = "0000D0"

  # Render a page header. Used on the manual lone pages and package
  # introductory pages
  #
  def pdf_header(pdf, str)
    pdf_header_box(pdf) do
      pdf.font_size(24) do
        pdf.text(str, color: BROWN, valign: :center, align: :center)
      end
    end
  end

  # Renders the page-wide headers
  #
  def pdf_header_box(pdf, &block)
    pdf.bounding_box([-pdf.bounds.absolute_left, pdf.cursor],
                 :width  => pdf.bounds.absolute_left + pdf.bounds.absolute_right,
                 :height => BOX_MARGIN * 2 + RHYTHM) do

      pdf.fill_color LIGHT_GRAY
      pdf.fill_rectangle([pdf.bounds.left, pdf.bounds.top],
                      pdf.bounds.right,
                      pdf.bounds.top - pdf.bounds.bottom)
      pdf.fill_color BLACK

      block.call(pdf)
    end

    pdf.stroke_color GRAY
    pdf.stroke_horizontal_line(-BOX_MARGIN * 2, pdf.bounds.width + BOX_MARGIN * 2, :at => pdf.cursor)
    pdf.stroke_color BLACK

    pdf.move_down(RHYTHM * 3)
  end

  def generate_magic_tokens
    first = true
    last_topic = nil
    magic_token = 0

    @instructable_magic_tokens = {}
    @instructables.each do |instructable|
      if last_topic != instructable.topic
        magic_token += 100 - (magic_token % 100)
        last_topic = instructable.topic
      end
      @instructable_magic_tokens[instructable.id] = magic_token
      magic_token += 1
    end
  end

  def render_pdf(filename, cache_filename = nil, user = nil)
    @instructables = Instructable.where(scheduled: true).order(:topic, :subtopic, :culture, :name)
    generate_magic_tokens

    pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :landscape,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{PENNSIC_YEAR} Class Schedule",
        :Author => "Pennsic University",
        :Subject => "Pennsic University #{PENNSIC_YEAR} Classes",
        :Keywords => "pennsic university classes",
        :Creator => "Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/",
        :Producer => "Pennsic Univeristy Class Maker",
        :CreationDate => Time.now,
    })

    header = [
      { content: "Id", background_color: 'ffffee' },
      { content: "When and Where", background_color: 'ffffee' },
      { content: "Title and Instructor", background_color: 'ffffee' }
    ]

    unless @omit_descriptions
      header << { content: "Description", background_color: 'ffffee' }
    end

    first_page = true
    for date in @dates
      items = [ header ]

      for event in @events[date]
        materials = []
        handout = []
        handout << "limit: #{event.instructable.handout_limit}" if event.instructable.handout_limit
        materials << "limit: #{event.instructable.material_limit}" if event.instructable.material_limit

        handout << "fee: $#{'%.2f' % event.instructable.handout_fee}" if event.instructable.handout_fee
        materials << "fee: $#{'%.2f' % event.instructable.material_fee}" if event.instructable.material_fee

        handout_content = nil
        handout_content = "Handout " + handout.join(", ") + '. ' if handout.size > 0

        materials_content = nil
        materials_content = "Materials " + materials.join(", ") + '. ' if materials.size > 0

        times = []
        times << event.start_time.strftime("%a %b %e")
        times << event.start_time.strftime("%I:%M %p") + " - " + event.end_time.strftime("%I:%M")
        times << event.formatted_location
        times_content = times.join("\n")

        new_items = [
          { content: @instructable_magic_tokens[event.instructable.id].to_s},
          { content: times_content },
          { content: [ event.instructable.name, event.instructable.user.titled_sca_name ].join("\n\n") },
        ]
        unless @omit_descriptions
          new_items << { content: [ event.instructable.description_book, [handout_content, materials_content].compact.join(' ') ].compact.join("\n") }
        end
        items << new_items
      end

      if @events[date].count > 0
        pdf.move_down 20 unless first_page
        first_page = false

        pdf.font_size 25
        pdf.text @formatted_dates[date]
        pdf.font_size 10
        pdf.move_down 10

        if @omit_descriptions
          column_widths = { 0 => 35, 1 => 180, 2 => 250 }
          total_width = column_widths.values.inject(:+)
        else
          column_widths = { 0 => 35, 1 => 100, 2 => 160 }
          total_width = 720
        end

        pdf.table(items, header: true, width: total_width,
          column_widths: column_widths,
          cell_style: { overflow: :shrink_to_fit, min_font_size: 8 })
      end
    end

    # Render class summary
    pdf.start_new_page(layout: :portrait)

    last_topic = nil

    @instructables.each do |instructable|
      pdf.group do
        if last_topic != instructable.topic
          pdf.move_down(RHYTHM * 2) unless pdf.cursor == pdf.bounds.top
          pdf_header(pdf, instructable.topic)
        end

        pdf.move_down RHYTHM * 1.5
        pdf.formatted_text [
          { text: "#{@instructable_magic_tokens[instructable.id]}: ", styles: [:bold], font_size: 13 },
          { text: instructable.name, font_size: 13 },
        ]
        topic = "Topic: #{instructable.formatted_topic}"
        culture = instructable.culture.present? ? "Culture: #{instructable.culture}" : nil
        pdf.text [topic, culture].compact.join(", ")
        pdf.text "Instructor: #{instructable.user.titled_sca_name}"
        pdf.text "Taught: " + instructable.instances.map(&:formatted_location_and_time).join(", ")
        pdf.move_down 5
        pdf.text instructable.description_web.present? ? instructable.description_web : instructable.description_book
      end

      last_topic = instructable.topic
    end

    # set page footer
    options = { :at => [pdf.bounds.left, 0],
                :width => pdf.bounds.right,
                :align => :center,
                :start_count_at => 1,
                :color => "007700",
                font_size: 10 }

    now = Time.now.strftime("%A, %B %d, %H:%M %p")
    pdf.number_pages "Generated on #{now} -- page <page> of <total>", options

    data = pdf.render
    #cache_in_file(cache_filename, data)
    send_data(data, type: Mime::PDF, disposition: "inline; filename=#{filename}", filename: filename)
  end

  def render_csv(filename)
    column_names = PennsicEvent.column_names - [ 'created_at', 'updated_at', 'start_date' ]
    data = CSV.generate do |csv|
      csv << column_names
      @events.each do |event|
        csv << event.attributes.values_at(*column_names)
      end
    end

    send_data(data, type: Mime::CSV, filename: filename)
  end

  def render_xlsx(filename)
      p = Axlsx::Package.new
      p.use_shared_strings = true

      wb = p.workbook

      wb.styles do |s|
        header_style = s.add_style :bg_color => "00", :fg_color => "FF"

        for date in @dates
          wb.add_worksheet(:name => @formatted_dates[date]) do |sheet|
            sheet.add_row [
              "ID",
              "DateTime",
              "Duration",
              "Title",
              "Subjects",
              "Source",
              "Description",
            ]

            for event in @events[date]
              sheet.add_row [
                event.id,
                event.start_time ? event.start_time.strftime("%y-%m-%d %H:%M") : nil,
                event.duration,
                event.title,
                [ event.subject, event.subject2 ].compact.join("\n"),
                event.data_source,
                event.description,
              ]
            end

            sheet.row_style 0, header_style
          end
        end
      end

      data = p.to_stream.read
      send_data(data, type: Mime::XLSX, filename: filename)
    end

  def cache_in_file(cache_filename, data)
    if cache_filename
      tmp_filename = [cache_filename, SecureRandom.hex(16)].join
      File.open(tmp_filename, "wb") do |f|
        f.write data
      end
      File.rename(tmp_filename, cache_filename)
    end
  end

  def load_data
    @dates = Instructable::CLASS_DATES
    @formatted_dates = {}

    for date in @dates
      @formatted_dates[date] = Time.parse(date).strftime("%A, %B %e").gsub(/\ +/, " ")
    end

    @events = {}
    for date in @dates
      @events[date] = Instance.for_date(date).order(:start_time, :location).includes(:instructable => [ :user ])
    end
  end
end
