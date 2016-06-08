require 'rubygems'

require 'prawn'
require 'json'
require 'pp'

include GriffinMarkdown

@render_notes_and_doodles = true

@location_label_width = 6
@header_height = 3
@row_height = 2
@column_width = 8

@title_font_size = 19

@grey = 'eeeeee'
@grey_dark = 'dddddd'
@grey_50 = '888888'
@grey_40 = '444444'
@grey_20 = '222222'
@black = '000000'
@white = 'ffffff'

entries = {}

# 24-hour times to display
@morning_hours =   [  9, 10, 11, 12, 13 ]
@afternoon_hours = [ 14, 15, 16, 17, 18 ]

@locs1 = (1..15).map { |x| "A&S #{x}" }
@locs1 << 'University-Battlefield'
@locs1 << 'Dance'
@locs1 << 'Games'

@locs2 = [
  'Performing Arts',
  'Amphitheater',
  'Middle Eastern',
  'Æthelmearc 1',
  'Æthelmearc 2',
  'Touch The Earth',
  'Performing Arts Rehearsal',
  'Livonia Smithery',
  'Pine Box Traders',
].sort

@loc_count = {}
@locs1.each { |loc| @loc_count[loc] = 0 }
@locs2.each { |loc| @loc_count[loc] = 0 }

def generate_magic_tokens(instructables)
  items = instructables.map { |x| [x.formatted_topic, x.name.gsub('*', ''), x.id] }.sort

  last_topic = nil
  magic_token = 0

  @instructable_magic_tokens = {}
  items.each do |item|
    if last_topic != item[0].split(':').first.strip
      magic_token += 100 - (magic_token % 100)
      last_topic = item[0].split(':').first.strip
    end
    @instructable_magic_tokens[item[2]] = magic_token
    magic_token += 1
  end
end

instructables = Instructable.where(schedule: 'Pennsic University')
generate_magic_tokens(instructables)

ids = instructables.map { |x| x.id }
instances = Instance.where(instructable_id: ids).includes(:instructable).select { |x| x.scheduled? }

instances.each do |instance|
  if instance.start_time.nil?
    pp instance
    next
  end

  date = instance.start_time.to_date

  entries[date] ||= {
    morning: { loc1: [], loc2: [] },
    afternoon: { loc1: [], loc2: [] },
    other_location: [],
    other_time: [],
    other: [],
  }

  hour = instance.start_time.hour
  morning_check = @morning_hours.index(hour)
  afternoon_check = @afternoon_hours.index(hour)
  actual_loc = instance.location.gsub(/ Tent$/, '')
  loc = instance.instructable.location_nontrack? ? instance.instructable.camp_name : actual_loc
  loc.gsub!(/ Tent$/, '')
  loc1_check = @locs1.index(loc) || @locs1.index(actual_loc)
  loc2_check = @locs2.index(loc) || @locs2.index(actual_loc)

  @loc_count[loc] ||= 0
  @loc_count[loc] += 1

  subsection = nil
  in_loc = false
  if not (morning_check or afternoon_check) or not (loc1_check or loc2_check)
    section = :other
    if (loc1_check or loc2_check) and hour < @morning_hours.first
      in_loc = true
    end
  elsif (loc1_check or loc2_check) and (morning_check)
    section = :morning
    subsection = loc1_check ? :loc1 : :loc2
  elsif (loc1_check or loc2_check) and (afternoon_check)
    section = :afternoon
    subsection = loc1_check ? :loc1 : :loc2
  else
    puts "OTHER:"
    pp instance
    section = :other
  end

  locindex = (loc1_check || loc2_check)
  hourindex = (morning_check || afternoon_check)

  duration = instance.instructable.duration
  minute = instance.start_time.strftime('%M').to_i

  if hourindex
    hourindex += (minute / 60.0)
    if (hourindex + duration) > 5
      display_duration = 5 - hourindex
      extended_right = true
    else
      display_duration = duration
      extended_right = false
    end
  else
    display_duration = duration
    extended_right = false
  end

  extended_left = false

  if instance.instructable.name == 'Bellatrix: Individual Session'
    start_time = "By appointment"
    section = :other
    subsection = nil
  else
    start_time = instance.start_time
  end

  data = {
    name: instance.instructable.name,
    start_time: start_time,
    hourindex: hourindex,
    locindex: locindex,
    duration: duration,
    display_duration: display_duration,
    id: @instructable_magic_tokens[instance.instructable.id],
    extended_right: extended_right,
    extended_left: extended_left,
    instance: instance,
  }

  spot = subsection ? entries[date][section][subsection] : entries[date][section]
  spot << data

  if in_loc and (hour + minute / 60.0 + duration > @morning_hours.first)
    display_duration = duration - (@morning_hours.first - (hour + minute / 60.0))
    name = instance.instructable.name
    name = 'Yoga' if name =~ /^Yoga/
    data = {
        name: name,
        start_time: start_time,
        hourindex: 0,
        locindex: locindex,
        duration: duration,
        display_duration: display_duration,
        id: @instructable_magic_tokens[instance.instructable.id],
        extended_right: extended_right,
        extended_left: true,
        instance: instance,
    }

    spot = entries[date][:morning][loc1_check ? :loc1 : :loc2]
    spot << data
  end

  if extended_right and section == :morning
    display_duration = duration - display_duration
    if display_duration > 5
      display_duration = 5
      extended_right = true
    else
      extended_right = false
    end

    data = {
      name: instance.instructable.name,
      start_time: instance.start_time,
      hourindex: 0,
      locindex: locindex,
      duration: duration,
      display_duration: display_duration,
      id: @instructable_magic_tokens[instance.instructable.id],
      extended_right: extended_right,
      extended_left: true,
      instance: instance,
    }
    spot = entries[date][:afternoon][subsection]
    spot << data
  end
end

def draw_hour_labels(pdf, opts)
  opts[:hour_labels].count.times do |timeindex|
    opts[:location_labels].count.times do |locindex|
      y1 = @header_height + locindex * @row_height
      x1 = @location_label_width + timeindex * @column_width
      y2 = y1 + @row_height - 1
      x2 = x1 - 1 + @column_width
      box = pdf.grid([y1, x1], [y2, x2])
      box.bounding_box {
        pdf.stroke_color @grey_dark
        pdf.fill_color @grey
        pdf.fill {
          pdf.rectangle [0, box.height], box.width, box.height
        }
        pdf.stroke_bounds
        pdf.stroke_color @black
        pdf.fill_color @black
      }
    end
  end

  opts[:hour_labels].each_with_index do |label, labelindex|
    y1 = @header_height - 1
    x1 = @location_label_width + labelindex * @column_width
    y2 = y1
    x2 = x1 + @column_width - 1
    box = pdf.grid([y1, x1], [y2, x2])

    box.bounding_box {
      pdf.fill_color @grey
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color @black
      pdf.stroke {
        #pdf.line [box.width, 0], box.width, box.height
        pdf.line [0, 0], 0, box.height
        pdf.line [0, 0], box.width, 0
      }
    }
    box_opts = {
        at: [box.top_left[0] + 2, box.top_left[1] - 2],
        width: box.width - 4,
        height: box.height - 4,
        size: 10,
        overflow: :shrink_to_fit,
        min_font_size: 6,
        align: :center,
        valign: :center,
        style: :bold,
    }
    if label < 12
      pdf.text_box "#{label}:00 am", box_opts
    else
      pm = label > 12 ? label - 12 : 12
      pdf.text_box "#{pm}:00 pm", box_opts
    end
  end
end

def draw_location_labels(pdf, opts)
  opts[:location_labels].each_with_index do |label, labelindex|
    y1 = @header_height + labelindex * @row_height
    x1 = 0
    y2 = y1 + @row_height - 1
    x2 = @location_label_width - 1
    box = pdf.grid([y1, x1], [y2, x2])
    box.bounding_box {
      pdf.fill_color @grey
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color @black
      pdf.stroke {
        pdf.line [0, box.height], box.width, box.height
        pdf.line [0, 0], box.width, 0
        pdf.line [box.width, 0], box.width, box.height
      }
    }
    box_opts = {
        at: [box.top_left[0] + 2, box.top_left[1] - 2],
        width: box.width - 4,
        height: box.height - 4,
        size: 9,
        overflow: :shrink_to_fit,
        min_font_size: 8,
        align: :center,
        valign: :center,
        style: :bold,
    }
    pdf.text_box label, box_opts
  end
end

def render(pdf, opts)
  debug = false

  if debug
    pdf.stroke_axis
  end

  pdf.line_width 0.25
  pdf.stroke_color @black

  hour_slots = opts[:hour_labels].count
  location_slots = opts[:location_labels].count
  location_slots = 18 if location_slots < 18

  pdf.define_grid(columns: hour_slots * 8 + 6, rows: location_slots * 2 + 2 + 1, gutter: 0)

  if debug
    (pdf.grid.rows - 1).times do |row|
      (pdf.grid.columns - 1).times do |column|
        pdf.grid([row, column], [row + 1, column + 1]).bounding_box do
          pdf.stroke_color @grey
          pdf.stroke_bounds
        end
      end
    end
    pdf.stroke_color @black
  end

  box = pdf.grid([0, 0], [@header_height - 1, pdf.grid.columns - 1])
  box.bounding_box do
    pdf.fill_color @grey
    pdf.stroke_color @grey
    pdf.fill { pdf.rectangle [0, box.height], box.width, box.height }
    pdf.stroke_bounds
  end

  box = pdf.grid([0, 0], [1, pdf.grid.columns - 1])
  msg = opts[:title]
  box_opts = {
    align: :center,
    valign: :center,
    size: @title_font_size,
    at: [box.top_left[0], box.top_left[1] - 2],
    width: box.width,
    height: box.height,
  }
  pdf.text_rendering_mode(:fill_stroke) do
    pdf.fill_color @grey_50
    pdf.stroke_color @grey_40
    pdf.font("TitleFont") do
      pdf.text_box msg, box_opts
    end
  end

  pdf.fill_color @black
  pdf.stroke_color @black

  draw_hour_labels(pdf, opts)
  draw_location_labels(pdf, opts)

  pdf.font_size 12
  opts[:entries].each do |data|
    locindex = data[:locindex]
    hourindex = data[:hourindex]
    display_duration = data[:display_duration]
    duration = data[:duration]

    extended_right = data[:extended_right]
    extended_left = data[:extended_left]

    y1 = @header_height + locindex * @row_height
    x1 = @location_label_width + hourindex.to_f * @column_width
    y2 = y1 + @row_height - 1
    x2 = x1 - 1 + display_duration * @column_width
    box = pdf.grid([y1, x1], [y2, x2])

    if extended_left
      at = [box.top_left[0] + 6, box.top_left[1] - 2]
    else
      at = [box.top_left[0] + 2, box.top_left[1] - 2]
    end

    box_opts = {
      at: at,
      width: box.width - 4,
      height: box.height - 4,
      size: 9,
      overflow: :shrink_to_fit,
      min_font_size: 8,
      leading: 0,
      inline_format: true,
    }

    box.bounding_box {
      pdf.fill_color @white
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color @black
      pdf.stroke_bounds
    }
    msg = "#{markdown_html data[:name]} <i>(#{data[:id]})</i>"
    if duration != display_duration
      msg += "<br/><b>(#{duration} hours)</b>"
    end
    pdf.text_box msg, box_opts

    if extended_right
      coords = [
        [box.top_right[0], box.top_right[1]],
        [box.top_right[0] + 5, (box.top_right[1] + box.bottom_right[1]) / 2],
        [box.bottom_right[0], box.bottom_right[1]]
      ]
      pdf.fill_polygon *coords
    end

    if extended_left
      coords = [
          [box.top_left[0], box.top_left[1]],
          [box.top_left[0] + 5, (box.top_left[1] + box.bottom_left[1]) / 2],
          [box.bottom_left[0], box.bottom_left[1]]
      ]
      pdf.fill_polygon *coords
    end
  end
end

def render_extra(pdf, opts)
  rowoffset = opts[:rowoffset]

  box = pdf.grid([rowoffset, 0], [pdf.grid.rows - 1, pdf.grid.columns - 1])
  box = pdf.grid([rowoffset, 0], [rowoffset + 1, pdf.grid.columns - 1])
  box.bounding_box do
    pdf.fill_color @grey
    pdf.stroke_color @grey
    pdf.fill { pdf.rectangle [0, box.height], box.width, box.height }
    pdf.stroke_bounds
  end

  msg = opts[:title]
  box_opts = {
      align: :center,
      valign: :center,
      size: @title_font_size,
      at: [box.top_left[0], box.top_left[1] - 2],
      width: box.width,
      height: box.height,
  }
  pdf.text_rendering_mode(:fill_stroke) do
    pdf.fill_color @grey_50
    pdf.stroke_color @grey_40
    pdf.font("TitleFont") do
      pdf.text_box msg, box_opts
    end
  end

  pdf.stroke_color @black
  pdf.fill_color @black
  rowoffset += 2

  entries_count = opts[:entries].count
  if entries_count < 25
    font_size = 7.8 + (25 - entries_count) / 10.0
    columns = 1
  else
    font_size = 8.5 - (entries_count / 30.0)
    columns = 2
  end

  first = true
  box = pdf.grid([rowoffset, 0], [pdf.grid.rows - 1, pdf.grid.columns - 1])
  pdf.column_box([box.top_left[0], box.top_left[1] - 3], columns: columns, width: box.width) do
    opts[:entries].each do |entry|
      pdf.move_down 2 unless first
      first = false
      if entry[:start_time].is_a?(String)
        start_time = entry[:instance].formatted_location
        start_time += " (#{entry[:start_time]})"
      else
        start_time = entry[:instance].formatted_location_and_time(:pennsic_time_only)
      end
      msg = "#{entry[:id]}: #{markdown_html(entry[:name])}, #{start_time}"
      duration = entry[:duration]
      if duration != 1
        msg += ", #{duration} hours"
      end
      pdf.text msg, size: font_size, inline_format: true
    end
  end
end

def render_notes(pdf, opts)
  rowoffset = opts[:rowoffset]
  draw_lines = opts[:mode] == :notes
  draw_box = opts[:mode] == :doodles

  line_box = pdf.grid([rowoffset + 2, 0], [pdf.grid.rows - 1, pdf.grid.columns - 1])

  if draw_box
    line_box.bounding_box do
      pdf.stroke_color @grey_40
      pdf.fill_color @grey_40
      pdf.stroke_bounds
    end
  end

  box = pdf.grid([rowoffset, 0], [rowoffset + 1, pdf.grid.columns - 1])
  box.bounding_box do
    pdf.fill_color @grey
    pdf.stroke_color @grey
    pdf.fill { pdf.rectangle [0, box.height], box.width, box.height }
    pdf.stroke_bounds
  end

  msg = opts[:title]
  box_opts = {
      align: :center,
      valign: :center,
      size: @title_font_size,
      at: [box.top_left[0], box.top_left[1] - 2],
      width: box.width,
      height: box.height,
  }
  pdf.text_rendering_mode(:fill_stroke) do
    pdf.fill_color @grey_50
    pdf.stroke_color @grey_40
    pdf.font("TitleFont") do
      pdf.text_box msg, box_opts
    end
  end

  if draw_lines
    rowoffset += 2

    pdf.stroke_color @grey_40
    pdf.fill_color @grey_40

    spacing = 25
    y = spacing
    pdf.move_down spacing

    while y < line_box.height
      pdf.stroke_horizontal_rule
      pdf.move_down spacing
      y += spacing
    end
  end

  pdf.stroke_color @black
  pdf.fill_color @black
end

def draftit(pdf)
  return
  pdf.save_graphics_state do
    pdf.soft_mask do
      pdf.rotate(45, origin: [0, 0]) do
        pdf.fill_color @grey_50
        pdf.draw_text "Draft", size: 200, at: [250, 0]
        pdf.fill_color @black
      end
    end

    pdf.rotate(45, origin: [0, 0]) do
      pdf.fill_color 'bbbbbb'
      pdf.draw_text "Draft", size: 200, at: [250, 0]
      pdf.fill_color @black
    end
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
  previous_topic = ''

  instructables.sort { |a, b|
    [a.formatted_topic, a.name.gsub('*', '')] <=> [b.formatted_topic, b.name.gsub('*', '')]
  }.each do |instructable|
    if instructable.topic != previous_topic
      pdf.move_down 7 unless pdf.cursor == pdf.bounds.top
      pdf.font_size @title_font_size
      pdf.text_rendering_mode(:fill_stroke) do
        pdf.fill_color @grey_50
        pdf.stroke_color @grey_40
        pdf.font("TitleFont") do
          pdf.text instructable.topic
        end
      end

      pdf.font_size 7.5
      pdf.fill_color @black
      pdf.stroke_color @black
    end
    previous_topic = instructable.topic

    pdf.move_down 5 unless pdf.cursor == pdf.bounds.top
    name = markdown_html(instructable.name, tags_remove: 'strong')
    token = @instructable_magic_tokens[instructable.id]
    topic = "Topic: #{instructable.formatted_topic}"
    culture = instructable.culture.present? ? "Culture: #{instructable.culture}" : nil

    heading = "<strong>#{token}</strong>: <strong>#{name}</strong>"

    lines = [
        heading,
        [topic, culture].compact.join(', '),
        "Instructor: #{instructable.user.titled_sca_name}",
    ]

    scheduled_instances = instructable.instances.select { |x| x.scheduled? }
    if scheduled_instances.count > 1 and scheduled_instances.map(&:formatted_location).uniq.count == 1
      lines << 'Taught: ' + scheduled_instances.map { |x| "#{x.start_time.strftime('%a %b %e %I:%M %p')}" }.join(', ')
      lines << 'Location: ' + scheduled_instances.first.formatted_location
    else
      lines << 'Taught: ' + scheduled_instances.map { |x| x.scheduled? ? "#{x.start_time.strftime('%a %b %e %I:%M %p')} #{x.formatted_location}" : nil }.compact.join(', ')
    end

    lines << materials_and_handout_content(instructable).join(' ')

    pdf.text lines.join("\n"), inline_format: true

    pdf.move_down 2 unless pdf.cursor == pdf.bounds.top
    pdf.text markdown_html(instructable.description_web.present? ? instructable.description_web : instructable.description_book), inline_format: true, align: :justify
  end
end

pdf = Prawn::Document.new(page_size: "LETTER",
                          page_layout: :portrait,
                          compress: true,
                          optimize_objects: true,
                          info: {
                            Title: "Pennsic Schedule",
                            Author: "thing.pennsicuniversity.org",
                            Subject: "Pennsic Schedule",
                            Keywords: "Pennsic Schedule",
                            Creator: "sched.rb",
                            CreationDate: Time.now
                          })

pdf.font_families.update(
  'TitleFont' => {
    normal: { file: Rails.root.join('app', 'assets', 'fonts', 'Arial.ttf') },
  },
  'BodyFont' => {
    normal: Rails.root.join('app', 'assets', 'fonts', 'Arial.ttf'),
    bold: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold.ttf'),
    italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Italic.ttf'),
    bold_italic: Rails.root.join('app', 'assets', 'fonts', 'Arial Bold Italic.ttf'),
  },
)
pdf.font 'BodyFont'
pdf.text "Spacer page"
pdf.start_new_page

@note_counter = 1
def next_note_type
  ret = [:notes, :doodles][@note_counter % 2]
  @note_counter += 1
  ret
end

entries.keys.sort.each do |key|
  day = key.strftime("%d").to_i
  date = key.strftime("%A, %B #{day.ordinalize}, A.S. L")
  render(pdf,
         location_labels: @locs1,
         hour_labels: @morning_hours,
         entries: entries[key][:morning][:loc1],
         title: "#{date} ~ Morning")
  draftit(pdf)
  pdf.start_new_page

 render(pdf,
         location_labels: @locs2,
         hour_labels: @morning_hours,
         entries: entries[key][:morning][:loc2],
         title: "#{date} ~ Morning")

  subentries = entries[key][:other]
  if subentries.count > 0
    subentries.sort! { |a, b| a[:start_time].to_i <=> b[:start_time].to_i }
    render_extra(pdf,
                 entries: subentries,
                 title: "#{date} ~ Additional Classes",
                 rowoffset: @locs2.count * @row_height + @header_height + 1)
  else
    render_notes(pdf,
                 mode: :notes,
                 title: "Notes",
                 rowoffset: @locs2.count * @row_height + @header_height + 1)
  end

  draftit(pdf)
  pdf.start_new_page

  render(pdf,
         location_labels: @locs1,
         hour_labels: @afternoon_hours,
         entries: entries[key][:afternoon][:loc1],
         title: "#{date} ~ Afternoon")
  draftit(pdf)
  pdf.start_new_page

  render(pdf,
         location_labels: @locs2,
         hour_labels: @afternoon_hours,
         entries: entries[key][:afternoon][:loc2],
         title: "#{date} ~ Afternoon")
  note_type = next_note_type
  if (@render_notes_and_doodles)
    render_notes(pdf,
                 mode: note_type,
                 title: (note_type == :notes ? 'Notes' : 'Notes and Doodles'),
                 rowoffset: @locs2.count * @row_height + @header_height + 1)
  end
  draftit(pdf)
  pdf.start_new_page
end

pdf.font 'BodyFont'

pdf.column_box([0, pdf.cursor ], columns: 3, spacer: 6, width: pdf.bounds.width) do
  render_topic_list(pdf, instructables)
end

pdf.render_file 'sched.pdf'

@loc_count.keys.sort.each { |x|
  puts (' %2d %s' % [@loc_count[x], x])
}
