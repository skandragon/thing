require 'csv'

class Admin::ReportsController < ApplicationController
  include GriffinPdf

  def kingdom_war_points
    respond_to do |format|

      format.csv {
        ret = CSV.generate do |csv|
          header = %w(start_time end_time)
          User::KINGDOMS.each do |kingdom|
            header << kingdom
          end

          csv << header

          Instructable::PENNSIC_DATES_RAW.each do |date|
            start_time = Time.parse("#{date}T12:00:00")
            end_time = start_time + 1.day

            instances = Instance.where("start_time >= '#{start_time}' AND start_time < '#{end_time}'")
            instructables = Instructable.where(id: instances.pluck(:instructable_id))
            users = User.where(id: instructables.pluck(:user_id))

            instructables = instructables.group_by { |x| x[:id] }
            users = users.group_by { |x| x[:id] }

            kingdoms = {}
            User::KINGDOMS.each do |kingdom|
              kingdoms[kingdom] = 0
            end

            instances.each do |instance|
              instructable = instructables[instance.instructable_id].first
              user = users[instructable.user_id].first

              kingdoms[user.kingdom] += instructable.duration if user.kingdom.present?
            end

            row = [ start_time, end_time ]
            User::KINGDOMS.each do |kingdom|
              row << kingdoms[kingdom].to_f
            end
            csv << row
          end
        end
        render text: ret, content_type: Mime[:csv], layout: false
      }
    end
  end

  def instructor_signin
    @instructors = User.where(:instructor => true).order('UPPER(sca_name) ASC')
    @instructables = Instructable.all.group_by(&:user_id)
    respond_to do |format|
      format.pdf {
        render_pdf
      }
      format.html {
        redirect_to :root, alert: 'Only PDF format for instructor sign-in is supported.'
      }
    end
  end

  private

  PDF_FONT_SIZE = 7.5

  def render_pdf
    @pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :portrait,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{Pennsic.year} Instructor Signup",
        :Author => 'Pennsic University',
        :Subject => "Pennsic University #{Pennsic.year}",
        :Keywords => 'pennsic university',
        :Creator => 'Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/',
        :Producer => 'Pennsic Univeristy Class Maker',
        :CreationDate => Time.now,
    })

    @pdf.font_size PDF_FONT_SIZE

    @pdf.font_families.update(
      'BodyFont' => {
        normal: Rails.root.join('app', 'assets', 'fonts', 'Arial.ttf'),
        bold: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold.ttf'),
        italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Italic.ttf'),
        bold_italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold Italic.ttf'),
      },
    )
    @pdf.font 'BodyFont'

    @last_letter = nil
    @first_name = true

    @instructors.each do |instructor|
      instructables = @instructables[instructor.id]
      next if instructables.blank?

      if @last_letter != instructor.sca_name[0].upcase
        @pdf.start_new_page(layout: :portrait) unless @last_letter.nil?
        @last_letter = instructor.sca_name[0].upcase
        @first_name = true
      end

      unless @first_name
        @pdf.move_down PDF_FONT_SIZE
        # pdf.stroke_horizontal_rule
        @pdf.move_down PDF_FONT_SIZE
      end
      @first_name = false
      render_instructor(instructor, instructables)
    end

    data = @pdf.render
    send_data(data, type: Mime[:pdf], disposition: 'inline; filename=instructor-signup.pdf', filename: 'instructor-signup.pdf')
  end

  def render_instructor(instructor, instructables)
    @pdf.formatted_text [ { text: instructor.sca_name, size: 14, styles: [:bold] } ]
    @pdf.move_down 10
    @pdf.text 'Signature: ______________________________________________    Camp Name: ______________________________________________________'
    @pdf.move_down 10

    render_instructables(instructables)
  end

  def render_instructables(instructables)
    instances = Instance.where(instructable_id: instructables.map(&:id)).order(:start_time).includes(:instructable)

    items = instances.map { |instance|
      [
        { content: instance.start_time.present? ? instance.start_time.strftime('%a %b %e %I:%M %p') : ''},
        { content: instance.end_time.present? ? instance.end_time.strftime('%I:%M %p') : ''},
        { content: instance.formatted_location },
        { content: markdown_html(instance.instructable.name), inline_format: true },
      ]
    }

    column_widths = { 0 => 80, 1 => 50, 2 => 91 }
    total_width = column_widths.values.inject(:+)
    column_widths[3] = @pdf.bounds.width - total_width
    total_width = @pdf.bounds.width

    header = [
      { content: 'Starts', background_color: 'eeeeee' },
      { content: 'Ends', background_color: 'eeeeee' },
      { content: 'Where', background_color: 'eeeeee' },
      { content: 'Title', background_color: 'eeeeee' },
    ]

    pdf_render_table(@pdf, items, header, total_width, column_widths)
  end
end
