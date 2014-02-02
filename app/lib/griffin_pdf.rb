module GriffinPdf
  def pdf_render_table(pdf, items, header, total_width, column_widths)
    return unless items.size > 0
    pdf.table([header] + items, header: true, width: total_width,
      column_widths: column_widths,
      cell_style: { border_width: 0.5, padding: 2 })
  end
end
