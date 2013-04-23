module GriffinPdf
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

  #
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

  #
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

  def pdf_render_table(pdf, items, header, total_width, column_widths)
    return unless items.size > 0
    pdf.table([header] + items, header: true, width: total_width,
      column_widths: column_widths,
      cell_style: { border_width: 0.5 })
  end
end
