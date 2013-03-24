require 'csv'

class CalendarsController < ApplicationController
  PENNSIC_YEAR = 42

  def index
    respond_to do |format|
      format.html {
        load_data
      }
      format.ics {
        filename = "pennsic-#{PENNSIC_YEAR}-all.ics"

        @calendar_name = "PennsicU #{PENNSIC_YEAR}"

        cache_filename = Rails.root.join("tmp", filename)
        if File.exists?(cache_filename)
          send_file(cache_filename, type: Mime::ICS, disposition: "inline; filename=#{filename}", filename: filename)
        else
          load_data
          render_ics(filename, cache_filename)
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
        load_data
        render_csv("pennsic-#{PENNSIC_YEAR}-full.csv")
      }
      format.xlsx {
        load_data
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

  def render_ics(filename, cache_filename = nil)
    now = Time.now.utc

    calendar = RiCal.Calendar do |cal|
      cal.default_tzid = "America/New_York"
      cal.prodid = "//flame.org//PennsicU Converter.0//EN"
      cal.add_x_property("X-WR-CALNAME", @calendar_name)
      cal.add_x_property("X-WR-RELCALID", make_uid(@calendar_name)) # should be static per calendar
      cal.add_x_property("X-WR-CALDESC", "PennsicU #{PENNSIC_YEAR} Class Schedule")
      cal.add_x_property("X-PUBLISHED-TTL", "3600")

      for instance in @instances
        cal.event do |event|
          instructable = instance.instructable
          prefix = []
          prefix << "Subject: #{instructable.formatted_topic}"
          prefix << "Instructor: #{instructable.titled_sca_name}"
          prefix << "Additional Instructors: #{instructable.additional_instructors.join(', ')}" if instructable.additional_instructors.present?
          prefix << "Material limit: #{instructable.material_limit}" if instructable.material_limit
          prefix << "Handout limit: #{instructable.handout_limit}" if instructable.handout_limit

          event.dtstamp = now
          event.created = instance.instructable.created_at
          event.dtstart = instance.start_time
          event.dtend = instance.end_time
          event.summary = instructable.name
          event.description = [ prefix.join("\n"), "", instructable.description_web ].join("\n")
          event.location = instance.formatted_location
          event.uid = make_uid(instance)
          event.transp = "OPAQUE"
          event.status = "CONFIRMED"
          event.sequence = instructable.updated_at.to_i
        end
      end
    end

    data = calendar.to_s.gsub("::", ":")
#    cache_in_file(cache_filename, data)
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

  def render_table(pdf, items, header)
    return unless items.size > 0
    if @omit_descriptions
      column_widths = { 0 => 35, 1 => 180, 2 => 250 }
      total_width = column_widths.values.inject(:+)
    else
      column_widths = { 0 => 35, 1 => 100, 2 => 160 }
      total_width = 720
    end

    pdf.table([header] + items, header: true, width: total_width,
      column_widths: column_widths,
      cell_style: { overflow: :shrink_to_fit, min_font_size: 8 })
  end

  def render_pdf(filename, cache_filename = nil, user = nil)
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
    last_date = nil
    items = []

    for instance in @instances
      if last_date != instance.start_time.to_date
        if items.size > 0
          render_table(pdf, items, header)
          items = []
        end

        pdf.move_down 20 unless first_page
        pdf.font_size 25
        pdf.text instance.start_time.to_date.to_s(:pennsic)
        pdf.font_size 10
        pdf.move_down 10
        last_date = instance.start_time.to_date

        first_page = false
      end

      materials = []
      handout = []
      handout << "limit: #{instance.instructable.handout_limit}" if instance.instructable.handout_limit
      materials << "limit: #{instance.instructable.material_limit}" if instance.instructable.material_limit

      handout << "fee: $#{'%.2f' % instance.instructable.handout_fee}" if instance.instructable.handout_fee
      materials << "fee: $#{'%.2f' % instance.instructable.material_fee}" if instance.instructable.material_fee

      handout_content = nil
      handout_content = "Handout " + handout.join(", ") + '. ' if handout.size > 0

      materials_content = nil
      materials_content = "Materials " + materials.join(", ") + '. ' if materials.size > 0

      times = []
      times << instance.start_time.strftime("%a %b %e")
      times << instance.start_time.strftime("%I:%M %p") + " - " + instance.end_time.strftime("%I:%M")
      times << instance.formatted_location
      times_content = times.join("\n")

      new_items = [
        { content: @instructable_magic_tokens[instance.instructable.id].to_s},
        { content: times_content },
        { content: [ instance.instructable.name, instance.instructable.user.titled_sca_name ].join("\n\n") },
      ]
      unless @omit_descriptions
        new_items << { content: [ instance.instructable.description_book, [handout_content, materials_content].compact.join(' ') ].compact.join("\n") }
      end
      items << new_items
    end

    render_table(pdf, items, header)

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
    column_names = %w(
      name track culture topic_and_subtopic
      adult_only
      description_book description_web
      duration fee_itemization handout_fee handout_limit material_fee
      material_limit repeat_count updated_at
    )
    data = CSV.generate do |csv|
      names = ['id', 'location', 'start_time', 'end_time', 'instructor' ] + column_names
      csv << names
      @instances.each do |instance|
        data = [instance.instructable.id, instance.formatted_location, instance.start_time, instance.end_time, instance.instructable.user.titled_sca_name ]
        data += instance.instructable.attributes.values_at(*column_names)
        csv << data
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
        date_format = wb.styles.add_style :format_code => 'MM-DD'
        time_format = wb.styles.add_style :format_code => 'hh:mm'

        column_names = %W(
          name track culture formatted_topic
          adult_only repeat_count updated_at
          description_book description_web
          duration fee_itemization handout_fee handout_limit material_fee
          material_limit
        )
        header = ['id', 'location', 'start_date', 'start_time', 'end_time', 'instructor' ] + column_names

        wb.add_worksheet(:name => "Pennsic #{PENNSIC_YEAR}") do |sheet|
          sheet.add_row header

          for instance in @instances
            instructable = instance.instructable
            user = instructable.user
            data = [instructable.id, instance.formatted_location, instance.start_time.to_date, instance.start_time.to_time, instance.end_time.to_time, instructable.titled_sca_name ]
            column_names.each do |column_name|
              data += [ instructable.send(column_name) ]
            end

            sheet.add_row data, style: [
              nil, nil, date_format, time_format, time_format, nil,
              nil, nil, nil, nil, nil, nil, date_format,
            ]
            sheet.column_widths 4, 10, 6, 6, 6, nil, nil, nil, nil, nil, nil, 4, 6
          end

          sheet.row_style 0, header_style
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
    @instructables = Instructable.where(scheduled: true).order(:topic, :subtopic, :culture, :name)
    @instances = Instance.where(instructable_id: @instructables.map(&:id)).order(:start_time, :location).includes(instructable: [:user])
  end
end
