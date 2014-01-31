require 'csv'

class Admin::ReportsController < ApplicationController
  include GriffinPdf

  PENNSIC_YEAR = 43

  def instructor_signin
    @instructors = User.where(:instructor => true).order("UPPER(sca_name) ASC")
    @instructables = Instructable.all.group_by(&:user_id)
    respond_to do |format|
      format.pdf {
        render_pdf
      }
    end
  end

  private

  PDF_FONT_SIZE = 7.5

  def render_pdf
    column_widths = { 0 => 95, 1 => 170 }
    total_width = 540

    pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :portrait,
      :compress => true, :optimize_objects => true,
      :info => {
        :Title => "Pennsic University #{PENNSIC_YEAR} Instructor Signup",
        :Author => 'Pennsic University',
        :Subject => "Pennsic University #{PENNSIC_YEAR}",
        :Keywords => 'pennsic university',
        :Creator => 'Pennsic Univeristy Class Maker, http://thing.pennsicuniversity.org/',
        :Producer => 'Pennsic Univeristy Class Maker',
        :CreationDate => Time.now,
    })

    pdf.font_size PDF_FONT_SIZE

    last_letter = nil
    first_name = true

    @instructors.each do |instructor|
      instructables = @instructables[instructor.id]
      next if instructables.blank?

      if (last_letter != instructor.sca_name[0].upcase)
        pdf.start_new_page(layout: :portrait) unless last_letter.nil?
        last_letter = instructor.sca_name[0].upcase
        first_name = true
      end

      unless first_name
        pdf.move_down PDF_FONT_SIZE
        # pdf.stroke_horizontal_rule
        pdf.move_down PDF_FONT_SIZE
      end
      first_name = false
      render_instructor(pdf, instructor, instructables)
    end

    data = pdf.render
    send_data(data, type: Mime::PDF, disposition: "inline; filename=instructor-signup.pdf", filename: "instructor-signup.pdf")
  end

  def render_instructor(pdf, instructor, instructables)
    pdf.formatted_text [ { text: instructor.sca_name, size: 14, styles: [:bold] } ]
    pdf.move_down 10
    pdf.text "Signature: ______________________________________________    Camp Name: ______________________________________________________"
    pdf.move_down 10

    render_instructables(pdf, instructables)
  end

  def render_instructables(pdf, instructables)
    instances = Instance.where(instructable_id: instructables.map(&:id)).order(:start_time).includes(:instructable)

    items = instances.map { |instance|
      [
        { content: instance.start_time.present? ? instance.start_time.strftime('%a %b %e %I:%M %p') : "" },
        { content: instance.end_time.present? ? instance.end_time.strftime('%I:%M %p') : "" },
        { content: instance.formatted_location },
        { content: markdown_html(instance.instructable.name), inline_format: true },
      ]
    }

    column_widths = { 0 => 80, 1 => 50, 2 => 91 }
    total_width = column_widths.values.inject(:+)
    column_widths[3] = pdf.bounds.width - total_width
    total_width = pdf.bounds.width

    header = [
      { content: "Starts", background_color: 'eeeeee' },
      { content: "Ends", background_color: 'eeeeee' },
      { content: "Where", background_color: 'eeeeee' },
      { content: "Title", background_color: 'eeeeee' },
    ]

    pdf_render_table(pdf, items, header, total_width, column_widths)
  end
end
