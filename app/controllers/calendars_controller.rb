require 'csv'

class CalendarsController < ApplicationController
  PENNSIC_YEAR = 42

  include GriffinPdf

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
        @no_page_numbers = params[:unnumbered].present?

        filename = [
          "pennsic-#{PENNSIC_YEAR}-all",
          @omit_descriptions ? "brief" : nil,
          @no_page_numbers ? "unnumbered" : nil,
        ].compact.join("-") + ".pdf"

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
    #cache_in_file(cache_filename, data)
    send_data(data, type: Mime::ICS, disposition: "inline; filename=#{filename}", filename: filename)
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

  def materials_and_handout_content(instructable)
    materials = []
    handout = []
    handout << "limit: #{instructable.handout_limit}" if instructable.handout_limit
    materials << "limit: #{instructable.material_limit}" if instructable.material_limit

    handout << "fee: $#{'%.2f' % instructable.handout_fee}" if instructable.handout_fee
    materials << "fee: $#{'%.2f' % instructable.material_fee}" if instructable.material_fee

    handout_content = nil
    handout_content = "Handout " + handout.join(", ") + '. ' if handout.size > 0

    materials_content = nil
    materials_content = "Materials " + materials.join(", ") + '. ' if materials.size > 0

    [ handout_content, materials_content ].compact
  end

  PDF_FONT_SIZE = 7.5

  def render_topic_list(pdf, instructables)
    pdf.move_down 8 unless pdf.cursor == pdf.bounds.top
    pdf.font_size 16
    pdf.text instructables.first.topic
    pdf.font_size PDF_FONT_SIZE

    instructables.each do |instructable|
      pdf.move_down 5 unless pdf.cursor == pdf.bounds.top
      name = markdown_html(instructable.name, tags_remove: 'strong')
      token = @instructable_magic_tokens[instructable.id]

      topic = "Topic: #{instructable.formatted_topic}"
      culture = instructable.culture.present? ? "Culture: #{instructable.culture}" : nil

      lines = [
        "<strong>#{token}</strong>: <strong>#{name}</strong>",
        [topic, culture].compact.join(", "),
        "Instructor: #{instructable.user.titled_sca_name}",
        "Taught: " + instructable.instances.map(&:formatted_start_time).join(", "),
        materials_and_handout_content(instructable).join(" "),
      ]
      pdf.text lines.join("\n"), inline_format: true

      pdf.move_down 2 unless pdf.cursor == pdf.bounds.top
      pdf.text markdown_html(instructable.description_web.present? ? instructable.description_web : instructable.description_book), inline_format: true, align: :justify
    end
  end

  def render_pdf(filename, cache_filename = nil, user = nil)
    generate_magic_tokens

    if @omit_descriptions
      column_widths = { 0 => 200  }
    else
      column_widths = { 0 => 95, 1 => 170 }
    end
    total_width = 540

    pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :portrait,
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
      { content: "When and Where", background_color: 'eeeeee' },
      { content: "Title and Instructor", background_color: 'eeeeee' }
    ]

    unless @omit_descriptions
      header << { content: "Description", background_color: 'eeeeee' }
    end

    first_page = true
    last_date = nil
    items = []

    for instance in @instances
      if last_date != instance.start_time.to_date
        if items.size > 0
          pdf_render_table(pdf, items, header, total_width, column_widths)
          items = []
        end

        unless pdf.cursor == pdf.bounds.top
          pdf.move_down 12
        end
        pdf.font_size 14
        pdf.text instance.start_time.to_date.strftime("%A, %B %e")
        pdf.font_size PDF_FONT_SIZE
        pdf.move_down PDF_FONT_SIZE
        last_date = instance.start_time.to_date

        first_page = false
      end

      if !@omit_descriptions and instance.formatted_location =~ /A\&S /
        times = []
        times << "#{instance.start_time.strftime('%a %b %e')} - #{instance.formatted_location}"
        times << "#{instance.start_time.strftime('%I:%M %p')} - #{instance.end_time.strftime('%I:%M')}"
        times_content = times.join("\n")

        location = nil
      else
        times = []
        times << instance.start_time.strftime('%a %b %e')
        times << "#{instance.start_time.strftime('%I:%M %p')} - #{instance.end_time.strftime('%I:%M')}"
        times_content = times.join(@omit_descriptions ? " " : "\n")
        location = instance.formatted_location
      end

      maybe_newline = @omit_descriptions ? " - " : "\n"

      token = @instructable_magic_tokens[instance.instructable.id].to_s
      new_items = [
        { content: [times_content, location].join(maybe_newline) },
        { content: [
          markdown_html(instance.instructable.name + " (#{token})"),
          "#{maybe_newline}#{instance.instructable.user.titled_sca_name}"
        ].join(" "), inline_format: true },
      ]
      unless @omit_descriptions
        taught_message = nil
        taught_message = "Taught #{helpers.pluralize(instance.instructable.repeat_count, 'time')}." if instance.instructable.repeat_count > 1
        new_items << {
          inline_format: true,
          content: markdown_html([
            instance.instructable.description_book,
            materials_and_handout_content(instance.instructable).join(" "),
            taught_message,
          ].compact.join(' '))
        }
      end
      items << new_items
    end

    pdf_render_table(pdf, items, header, total_width, column_widths)

    # Render class summary
    pdf.start_new_page(layout: :portrait)

    instructables = []
    last_topic = nil

    pdf.column_box([0, pdf.cursor ], columns: 2, spacer: 10, width: pdf.bounds.width) do
      @instructables.each do |instructable|
        if last_topic != instructable.topic && !instructables.empty?
          render_topic_list(pdf, instructables)
          instructables = []
        end

        last_topic = instructable.topic
        instructables << instructable
      end

      unless instructables.empty?
        render_topic_list(pdf, instructables)
        instructables = []
      end
    end

    # set page footer
    options = { :at => [pdf.bounds.left, -5],
                :width => pdf.bounds.right,
                :align => :center,
                :start_count_at => 1,
                font_size: 6 }

    unless @no_page_numbers
      now = Time.now.in_time_zone.strftime("%A, %B %d, %H:%M %p")
      pdf.number_pages "Generated on #{now} -- page <page> of <total>", options
    end

    data = pdf.render
    cache_in_file(cache_filename, data)
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
      header_style = s.add_style bg_color: "00", fg_color: "FF"
      date_format = wb.styles.add_style format_code: 'MM-DD hh:mm'

      column_names = %W(
        name track culture formatted_topic
        adult_only repeat_count updated_at
        description_book description_web
        duration fee_itemization handout_fee handout_limit material_fee
        material_limit
      )
      header = ['id', 'location', 'start_time', 'end_time', 'instructor' ] + column_names

      wb.add_worksheet(name: "Pennsic #{PENNSIC_YEAR}") do |sheet|
        sheet.add_row header

        for instance in @instances
          instructable = instance.instructable
          user = instructable.user
          start_time = Time.at(instance.start_time.to_f + instance.start_time.utc_offset.to_f)
          end_time = Time.at(instance.end_time.to_f + instance.end_time.utc_offset.to_f)
          data = [instructable.id, instance.formatted_location, start_time, end_time, instructable.titled_sca_name ]
          column_names.each do |column_name|
            data += [ instructable.send(column_name) ]
          end

          sheet.add_row data, style: [
            nil, nil, date_format, date_format, nil,
            nil, nil, nil, nil, nil, nil, date_format,
          ]
          sheet.column_widths 4, 10, 10, 10, nil, nil, nil, nil, nil, nil, 4, 6
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
    @instructables = Instructable.where(scheduled: true).order(:topic, :subtopic, :culture, :name).includes(:instances, :user)
    @instances = Instance.where(instructable_id: @instructables.map(&:id)).order("start_time, btrsort(location)").includes(instructable: [:user])
  end
end
