require 'csv'

class CalendarRenderer
  include GriffinPdf
  include GriffinMarkdown

  PDF_FONT_SIZE = 7.5

  def initialize(instances, instructables)
    @instances = instances
    @instructables = instructables
  end

  def render_ics(options, filename, cache_filename = nil)
    @options = options
    @options = {} if options.nil?
    @options.reverse_merge!({
      calendar_name: "Pennsic #{Pennsic.year} Class Schedule",
      calendar_id: 'all',
    })

    now = Time.now.utc

    calendar = RiCal.Calendar do |cal|
      cal.default_tzid = 'America/New_York'
      cal.prodid = '//flame.org//PennsicU Converter.0//EN'
      cal.add_x_property('X-WR-CALNAME', @options[:calendar_name])
      cal.add_x_property('X-WR-RELCALID', make_uid) # should be static per calendar
      cal.add_x_property('X-WR-CALDESC', "PennsicU #{Pennsic.year} Class Schedule")
      cal.add_x_property('X-PUBLISHED-TTL', '3600')

      @instances.each { |instance|
        cal.event do |event|
          instructable = instance.instructable
          prefix = []
          prefix << "Subject: #{instructable.formatted_topic}"
          prefix << "Instructor: #{instructable.titled_sca_name}"
          prefix << "Additional Instructors: #{instructable.additional_instructors.join(', ')}" if instructable.additional_instructors.present?
          prefix << "Material limit: #{instructable.material_limit}" if instructable.material_limit
          prefix << "Handout limit: #{instructable.handout_limit}" if instructable.handout_limit

          suffix = []
          if instructable.instances.count > 1 and instructable.instances.map(&:formatted_location).uniq.count == 1
            dates = []
            instructable.instances.each do |inst|
              dates << inst.start_time.strftime('%a %b %e %I:%M %p') if inst != instance
            end
            suffix << 'Also Taught: ' + dates.join(', ')
          end

          event.dtstamp = now
          event.created = instance.instructable.created_at
          if instance.start_time
            event.dtstart = instance.start_time
            event.dtend = instance.end_time
          end
          event.summary = instructable.name
          event.description = [prefix.join("\n"), '', instructable.description_web, '', suffix.join("\n")].join("\n")
          event.location = instance.formatted_location
          event.uid = make_uid(instance.to_s)
          event.transp = 'OPAQUE'
          event.status = 'CONFIRMED'
          event.sequence = instructable.updated_at.to_i
        end
      }
    end

    calendar.to_s.gsub('::', ':')
  end

  def render_pdf(options, filename, cache_filename = nil, user = nil)
    @options = options
    @options = {} if @options.nil?
    @options.reverse_merge!({
      user: nil,
      omit_descriptions: false,
      no_page_numbers: false,
      no_long_descriptions: false,
    })

    generate_magic_tokens unless @options[:no_long_descriptions].present?

    if @options[:omit_descriptions]
      column_widths = { 0 => 200  }
    else
      column_widths = { 0 => 95, 1 => 170 }
    end
    total_width = 540

    pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :portrait,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{Pennsic.year} Class Schedule",
        :Author => 'Pennsic University',
        :Subject => "Pennsic University #{Pennsic.year} Classes",
        :Keywords => 'pennsic university classes',
        :Creator => 'Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/',
        :Producer => 'Pennsic Univeristy Class Maker',
        :CreationDate => Time.now,
    })

    header = [
      { content: 'When and Where', background_color: 'eeeeee' },
      { content: 'Title and Instructor', background_color: 'eeeeee' }
    ]

    unless @options[:omit_descriptions]
      header << { content: 'Description', background_color: 'eeeeee' }
    end

    last_date = nil
    items = []

    @instances.each { |instance|
      if last_date != instance.start_time.to_date
        if items.size > 0
          pdf_render_table(pdf, items, header, total_width, column_widths)
          items = []
        end

        unless pdf.cursor == pdf.bounds.top
          pdf.move_down 12
        end
        pdf.font_size 14
        pdf.text instance.start_time.to_date.strftime('%A, %B %e')
        pdf.font_size PDF_FONT_SIZE
        pdf.move_down PDF_FONT_SIZE
        last_date = instance.start_time.to_date
      end

      if !@options[:omit_descriptions] and instance.formatted_location =~ /A\&S /
        times = []
        times << "#{instance.start_time.strftime('%a %b %e')} - #{instance.formatted_location}"
        times << "#{instance.start_time.strftime('%I:%M %p')} - #{instance.end_time.strftime('%I:%M')}"
        times_content = times.join("\n")

        location = nil
      else
        times = []
        times << instance.start_time.strftime('%a %b %e')
        times << "#{instance.start_time.strftime('%I:%M %p')} - #{instance.end_time.strftime('%I:%M')}"
        times_content = times.join(@options[:omit_descriptions] ? ' ' : "\n")
        location = instance.formatted_location
      end

      maybe_newline = @options[:omit_descriptions] ? ' - ' : "\n"

      unless @options[:no_long_descriptions].present?
        token = @instructable_magic_tokens[instance.instructable.id].to_s
      end
      new_items = [
          {content: [times_content, location].join(maybe_newline)},
          {content: [
              markdown_html(instance.instructable.name),
              @options[:no_long_descriptions].present? ? '' : " (#{token})",
              "#{maybe_newline}#{instance.instructable.user.titled_sca_name}"
          ].join(' '), inline_format: true},
      ]
      unless @options[:omit_descriptions]
        taught_message = nil
        if instance.instructable.repeat_count > 1
          times = instance.instructable.instances.pluck(:start_time)
          formatted_times = times.select { |t| t != instance.start_time }.map { |t| t.strftime('%m/%d') }.join(', ')
          taught_message = "Also taught #{formatted_times}"
        end
        new_items << {
          inline_format: true,
          content: markdown_html([
                                    instance.instructable.description_book,
                                    materials_and_handout_content(instance.instructable).join(' '),
                                    taught_message,
                                 ].compact.join(' '))
        }
      end
      items << new_items
    }

    pdf_render_table(pdf, items, header, total_width, column_widths)

    unless @options[:no_long_descriptions].present?
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
    end

    # set page footer
    render_options = { :at => [pdf.bounds.left, -5],
                :width => pdf.bounds.right,
                :align => :center,
                :start_count_at => 1,
                font_size: 6 }

    for_user = ''
    for_user = "-- for #{@options[:user].best_name}" if @options[:user]

    unless @options[:no_page_numbers]
      now = Time.now.in_time_zone.strftime('%A, %B %d, %H:%M %p')
      pdf.number_pages "Generated on #{now} #{for_user} -- page <page> of <total>", render_options
    end

    pdf.render
  end

  def render_csv(options, filename)
    @options = options
    @options = {} if @options.nil?

    column_names = %w(
      name track culture topic_and_subtopic
      adult_only
      description_book description_web
      duration fee_itemization handout_fee handout_limit material_fee
      material_limit repeat_count updated_at
    )
    CSV.generate do |csv|
      names = %w(id location start_time end_time instructor instance_id) + column_names
      csv << names
      @instances.each do |instance|
        next unless instance.scheduled?
        data = [instance.instructable.id, instance.formatted_location, instance.start_time, instance.end_time, instance.instructable.user.titled_sca_name, instance.id ]
        data += instance.instructable.attributes.values_at(*column_names)
        csv << data
      end
    end
  end

  def render_xlsx(options, filename)
    @options = options
    @options = {} if @options.nil?

    p = Axlsx::Package.new
    p.use_shared_strings = true

    wb = p.workbook

    wb.styles do |s|
      header_style = s.add_style bg_color: '00', fg_color: 'FF'
      date_format = wb.styles.add_style format_code: 'MM-DD hh:mm'

      column_names = %W(
        name track culture formatted_topic
        adult_only repeat_count updated_at
        description_book description_web
        duration fee_itemization handout_fee handout_limit material_fee
        material_limit
      )
      header = %w(id location start_time end_time instructor) + column_names

      wb.add_worksheet(name: "Pennsic #{Pennsic.year}") do |sheet|
        sheet.add_row header

        @instances.each { |instance|
          instructable = instance.instructable
          start_time = Time.at(instance.start_time.to_f + instance.start_time.utc_offset.to_f)
          end_time = Time.at(instance.end_time.to_f + instance.end_time.utc_offset.to_f)
          data = [instructable.id, instance.formatted_location, start_time, end_time, instructable.titled_sca_name]
          column_names.each do |column_name|
            data += [instructable.send(column_name)]
          end

          sheet.add_row data, style: [
              nil, nil, date_format, date_format, nil,
              nil, nil, nil, nil, nil, nil, date_format,
          ]
          sheet.column_widths 4, 10, 10, 10, nil, nil, nil, nil, nil, nil, 4, 6
        }

        sheet.row_style 0, header_style
      end
    end

    p.to_stream.read
  end

  private

  def generate_magic_tokens
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
    handout_content = 'Handout ' + handout.join(', ') + '. ' if handout.size > 0

    materials_content = nil
    materials_content = 'Materials ' + materials.join(', ') + '. ' if materials.size > 0

    [ handout_content, materials_content ].compact
  end

  def render_topic_list(pdf, instructables)
    pdf.move_down 8 unless pdf.cursor == pdf.bounds.top
    pdf.font_size 16
    pdf.text instructables.first.topic
    pdf.font_size PDF_FONT_SIZE

    instructables.each do |instructable|
      pdf.move_down 5 unless pdf.cursor == pdf.bounds.top
      name = markdown_html(instructable.name, tags_remove: 'strong')

      if @instructable_magic_tokens
        token = @instructable_magic_tokens[instructable.id]
      end

      topic = "Topic: #{instructable.formatted_topic}"
      culture = instructable.culture.present? ? "Culture: #{instructable.culture}" : nil

      if token.present?
        heading = "<strong>#{token}</strong>: <strong>#{name}</strong>"
      else
        heading = "<strong>#{name}</strong>"
      end

      lines = [
        heading,
        [topic, culture].compact.join(', '),
        "Instructor: #{instructable.user.titled_sca_name}",
      ]

      if instructable.instances.count > 1 and instructable.instances.map(&:formatted_location).uniq.count == 1
        lines << 'Taught: ' + instructable.instances.map { |x| "#{x.start_time.strftime('%a %b %e %I:%M %p')}" }.join(', ')
        lines << 'Location: ' + instructable.instances.first.formatted_location
      else
        lines << 'Taught: ' + instructable.instances.map { |x| "#{x.start_time.strftime('%a %b %e %I:%M %p')} #{x.formatted_location}" }.join(', ')
      end

      lines << materials_and_handout_content(instructable).join(' ')

      pdf.text lines.join("\n"), inline_format: true

      pdf.move_down 2 unless pdf.cursor == pdf.bounds.top
      pdf.text markdown_html(instructable.description_web.present? ? instructable.description_web : instructable.description_book), inline_format: true, align: :justify
    end
  end

  def make_uid(*items)
    items << @options[:calendar_id] or 'all'
    d = Digest::SHA1.new
    d << items.join('/')
    d.hexdigest + '@pennsic.flame.org'
  end
end
