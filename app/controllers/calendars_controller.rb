class CalendarsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.ics {
        filename = "pennsic.ics"

        @events = PennsicEvent.where("start_time IS NOT NULL")
        @calendar_name = "PennsicU"

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
          filename = "pennsic-42-all-brief.pdf"
        else
          filename = "pennsic-42-all.pdf"
        end

        cache_filename = Rails.root.join("tmp", filename)
        if File.exists?(cache_filename)
          send_file(cache_filename, type: Mime::PDF, disposition: "inline; filename=#{filename}", filename: filename)
        else
          @dates = Instructable::CLASS_DATES
          @formatted_dates = {}

          for date in @dates
            @formatted_dates[date] = Time.parse(date).strftime("%A, %B %e").gsub(/\ +/, " ")
          end

          @events = {}
          for date in @dates
            @events[date] = Instance.for_date(date).order(:start_time, :location)
          end

          render_pdf(filename, cache_filename)
        end
      }
      format.csv {
        @events = PennsicEvent.order(:start_time, :title)

        render_csv("pennsic-full.csv")
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

        render_xlsx("pennsic-full.xlsx")
      }
    end
  end

  def show
    @dates = Instructable::CLASS_DATES
    @formatted_dates = {}
    @dates.each do |date|
      @formatted_dates[date] = Date.parse(date).to_s(:pennsic)
    end

    @events = {}
    @dates.each do |date|
      @events[date] = Instance.where("DATE_TRUNC('day', start_time) = ?", date).order(:start_time, :location)
    end

    respond_to do |format|
      format.html { }
      format.ics {
        @calendar_name = "PennsicU 42"
        render_calendar("pennsic-42-all.ics")
      }
      format.pdf {
        @omit_descriptions = params[:brief].present?

        render_pdf("pennsic-42-all.pdf", nil, @user)
      }
      format.csv {
        render_csv("pennsic-42-all.csv")
      }
      format.xlsx {
        render_xlsx("pennsic-42-all.xlsx")
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
      cal.add_x_property("X-WR-CALDESC", "PennsicU 42 Class Schedule")
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

  def render_pdf(filename, cache_filename = nil, user = nil)
    first = true

    pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :landscape,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University Class Schedule",
        :Author => "Pennsic University",
        :Subject => "Pennsic University Classes",
        :Keywords => "pennsic classes",
        :Creator => "Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/",
        :Producer => "Pennsic Univeristy Class Maker",
        :CreationDate => Time.now,
    })

    header = [
      { content: "Times", background_color: 'ffffee' },
      { content: "Title and Subject", background_color: 'ffffee' },
      { content: "Location and Fees", background_color: 'ffffee' },
      { content: "Limits", background_color: 'ffffee' }
    ]

    for date in @dates
      items = [ header ]

      for event in @events[date]
        limits = []
        limits << "Handout: #{event.instructable.handout_limit}" if event.instructable.handout_limit
        limits << "Materials: #{event.instructable.material_limit}" if event.instructable.material_limit

        times = event.start_time.strftime("%a %b %e") + "\n" + event.start_time.strftime("%I:%M %p") + " - " + event.end_time.strftime("%I:%M %p")

        fees = []
        fees << "Handout: #{event.instructable.handout_fee}" if event.instructable.handout_fee
        fees << "Materials: #{event.instructable.material_fee}" if event.instructable.material_fee

        items << [
          { content: times },
          { content: event.instructable.name },
          { content: [ event.formatted_location, fees ].compact.join("\n") },
          { content: [ limits ].join("\n") },
        ]
        unless @omit_descriptions
          items << [
            { content: (event.instructable.description_book || "No description provided."), colspan: 4 },
          ]
        end
      end

      if @events[date].count > 0
        pdf.start_new_page unless first
        first = false

        pdf.font_size(25)
        pdf.text @formatted_dates[date]
        pdf.font_size 10
        pdf.text "(#{@events[date].count} events)"
        pdf.move_down 10

        pdf.table(items, header: true, width: 720,
          cell_style: { overflow: :shrink_to_fit, min_font_size: 10 })
      end
    end

    options = { :at => [pdf.bounds.left, 0],
                :width => pdf.bounds.right,
                :align => :center,
                :start_count_at => 1,
                :color => "007700" }

    now = Time.now.strftime("%A, %B %d, %H:%M %p")
    pdf.number_pages "Generated on #{now} -- page <page> of <total> -- http://thing.pennsicuniversity.org/", options

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
end
