require 'rubygems'

require 'prawn'
require 'json'
require 'pp'

include GriffinMarkdown

@titles = Instructable.pluck(:name)

entries = {}

@morning_hours = [
  '9am', '10am', '11am', '12pm', '1pm'
]

@afternoon_hours = [
  '2pm', '3pm', '4pm', '5pm', '6pm'
]

@locs1 = (1..17).map { |x| "A&S #{x}" }
@locs1 << "Games"

@locs2 = ["Battlefield", 'Performing Arts', 'Amphitheater', 'Middle Eastern', 'Dance',
  'Æthelmearc 1', 'Æthelmearc 2', 'Æthelmearc 3', 'Æthelmearc Cooking Lab'
]

@wanted_tracks = [
  'Pennsic University',
  'Archery',  # should remove war points, etc
  'Cooking Lab',
  'European Dance',
  'First Aid',
  'Games',
  'Glass',
  'Heraldry',
  'In Persona',
  'Martial',
  'Middle Eastern',
  'Parent/Child',
  'Performing Arts and Music',
  'Rapier',
  'Thrown Weapons',
  'Youth Combat',
  'Æthelmearc Scribal',
]

def wanted(instance)
  instructable = instance.instructable
  return false unless @wanted_tracks.include?(instructable.track)
  true
end

Instance.includes(:instructable).each do |instance|
  if instance.start_time.nil?
    pp instance
    next
  end

  next unless wanted(instance)

  date = instance.start_time.to_date

  entries[date] ||= {
    morning: { loc1: [], loc2: [] },
    afternoon: { loc1: [], loc2: [] },
    other_location: [],
    other_time: [],
    other: [],
  }

  hour = instance.start_time.strftime("%l%p").strip.downcase
  morning_check = @morning_hours.index(hour)
  afternoon_check = @afternoon_hours.index(hour)
  loc = instance.formatted_location.gsub(/ Tent$/, '')
  loc1_check = @locs1.index(loc)
  loc2_check = @locs2.index(loc)

  subsection = nil
  if (morning_check or afternoon_check) and not (loc1_check or loc2_check)
    section = :other_location
  elsif (loc1_check or loc2_check) and not (morning_check or afternoon_check)
    section = :other_time
  elsif (loc1_check or loc2_check) and (morning_check)
    section = :morning
    subsection = loc1_check ? :loc1 : :loc2
  elsif (loc1_check or loc2_check) and (afternoon_check)
    section = :afternoon
    subsection = loc1_check ? :loc1 : :loc2
  else
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

  data = {
    name: markdown_html(instance.instructable.name),
    start_time: instance.start_time,
    hour: hour,
    hourindex: hourindex,
    loc: loc,
    locindex: locindex,
    duration: duration,
    display_duration: display_duration,
    id: instance.instructable.id,
    extended_right: extended_right,
    extended_left: extended_left,
  }

  spot = subsection ? entries[date][section][subsection] : entries[date][section]
  spot << data

  if extended_right and section == :morning

    display_duration = duration - display_duration
    if display_duration > 5
      display_duration = 5
      extended_right = true
    else
      extended_right = false
    end

    data = {
      name: markdown_html(instance.instructable.name),
      start_time: instance.start_time,
      hour: hour,
      hourindex: 0,
      loc: loc,
      locindex: locindex,
      duration: duration,
      display_duration: display_duration,
      id: instance.instructable.id,
      extended_right: extended_right,
      extended_left: true,
    }
    spot = entries[date][:afternoon][subsection]
    spot << data
  end
end

def render(pdf, opts)
  debug = true

  font_path = "EagleLake-Regular.ttf"
  pdf.font_families["TitleFont"] = {
    normal: { file: font_path, font: 'TitleFont' },
  }

  if debug
    pdf.stroke_axis
  end

  pdf.line_width 0.25
  pdf.stroke_color '000000'

  hour_slots = opts[:hour_labels].count
  location_slots = opts[:location_labels].count
  location_slots = 18 if location_slots < 18

  pdf.define_grid(columns: hour_slots * 8 + 6, rows: location_slots * 2 + 2 + 1, gutter: 0)

  if debug
    (pdf.grid.rows - 1).times do |row|
      (pdf.grid.columns - 1).times do |column|
        pdf.grid([row, column], [row + 1, column + 1]).bounding_box do
          pdf.stroke_color 'eeeeee'
          pdf.stroke_bounds
        end
      end
    end
    pdf.stroke_color '000000'
  end

  box = pdf.grid([0, 0], [opts[:rowoffset] - 1, pdf.grid.columns - 1])
  box.bounding_box do
    pdf.fill_color 'eeeeee'
    pdf.stroke_color 'eeeeee'
    pdf.fill { pdf.rectangle [0, box.height], box.width, box.height }
    pdf.stroke_bounds
  end

  box = pdf.grid([0, 0], [1, pdf.grid.columns - 1])
  msg = opts[:title]
  box_opts = {
    align: :center,
    valign: :center,
    size: 18,
    at: [box.top_left[0], box.top_left[1] - 2],
    width: box.width,
    height: box.height,
  }
  pdf.text_rendering_mode(:fill_stroke) do
    pdf.fill_color '888888'
    pdf.stroke_color '444444'
    pdf.font("TitleFont") do
      pdf.text_box msg, box_opts
    end
  end

  pdf.fill_color '000000'
  pdf.stroke_color '000000'

  opts[:hour_labels].count.times do |timeindex|
    opts[:location_labels].count.times do |locindex|
      y1 = opts[:rowoffset] + locindex * opts[:rowsize]
      x1 = opts[:columnoffset] + timeindex * opts[:columnsize]
      y2 = y1 + opts[:rowsize] - 1
      x2 = x1 - 1 + opts[:columnsize]
      box = pdf.grid([y1, x1], [y2, x2])
      box.bounding_box {
        pdf.stroke_color 'dddddd'
        pdf.fill_color 'eeeeee'
        pdf.fill {
          pdf.rectangle [0, box.height], box.width, box.height
        }
        pdf.stroke_bounds
        pdf.stroke_color '000000'
        pdf.fill_color '000000'
      }
    end
  end

  opts[:hour_labels].each_with_index do |label, labelindex|
    y1 = opts[:rowoffset] - 1
    x1 = opts[:columnoffset] + labelindex * opts[:columnsize]
    y2 = y1
    x2 = x1 + opts[:columnsize] - 1
    box = pdf.grid([y1, x1], [y2, x2])
    box.bounding_box {
      pdf.fill_color 'eeeeee'
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color '000000'
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
    pdf.text_box label, box_opts
  end

  opts[:location_labels].each_with_index do |label, labelindex|
    y1 = opts[:rowoffset] + labelindex * opts[:rowsize]
    x1 = 0
    y2 = y1 + opts[:rowsize] - 1
    x2 = opts[:columnoffset] - 1
    box = pdf.grid([y1, x1], [y2, x2])
    box.bounding_box {
      pdf.fill_color 'eeeeee'
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color '000000'
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
      size: 10,
      overflow: :shrink_to_fit,
      min_font_size: 6,
      align: :center,
      valign: :center,
      style: :bold,
    }
    pdf.text_box label, box_opts
  end

  pdf.font_size 12
  opts[:entries].each do |data|
    locindex = data[:locindex]
    timeindex = data[:hourindex]
    display_duration = data[:display_duration]
    duration = data[:duration]

    extended_right = data[:extended_right]
    extended_left = data[:extended_left]

    y1 = opts[:rowoffset] + locindex * opts[:rowsize]
    x1 = opts[:columnoffset] + timeindex * opts[:columnsize]
    y2 = y1 + opts[:rowsize] - 1
    x2 = x1 - 1 + display_duration * opts[:columnsize]
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
      min_font_size: 5,
      leading: 0,
      inline_format: true,
    }

    box.bounding_box {
      pdf.fill_color 'ffffff'
      pdf.fill {
        pdf.rectangle [0, box.height], box.width, box.height
      }
      pdf.fill_color '000000'
      pdf.stroke_bounds
    }
    msg = "#{data[:name]} <i>(#{data[:id]})</i>"
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

def draftit(pdf)
  pdf.save_graphics_state do
    pdf.soft_mask do
      pdf.rotate(45, origin: [0, 0]) do
        pdf.fill_color '888888'
        pdf.draw_text "Draft", size: 200, at: [250, 0]
        pdf.fill_color '000000'
      end
    end

    pdf.rotate(45, origin: [0, 0]) do
      pdf.fill_color 'bbbbbb'
      pdf.draw_text "Draft", size: 200, at: [250, 0]
      pdf.fill_color '000000'
    end
  end
end

pdf = Prawn::Document.new(page_size: "LETTER", page_layout: :portrait)

entries.keys.sort.each do |key|
  render(pdf,
         location_labels: @locs1,
         hour_labels: @morning_hours,
         entries: entries[key][:morning][:loc1],
         columnoffset: 6,
         rowoffset: 3,
         columnsize: 8,
         rowsize: 2,
         title: "#{key} ~ Morning")
  draftit(pdf)
  pdf.start_new_page

  render(pdf,
         location_labels: @locs2,
         hour_labels: @morning_hours,
         entries: entries[key][:morning][:loc2],
         columnoffset: 6,
         rowoffset: 3,
         columnsize: 8,
         rowsize: 2,
         title: "#{key} ~ Morning")
  draftit(pdf)
  pdf.start_new_page

  render(pdf,
         location_labels: @locs1,
         hour_labels: @afternoon_hours,
         entries: entries[key][:afternoon][:loc1],
         columnoffset: 6,
         rowoffset: 3,
         columnsize: 8,
         rowsize: 2,
         title: "#{key} ~ Afternoon")
  draftit(pdf)
  pdf.start_new_page

  render(pdf,
         location_labels: @locs2,
         hour_labels: @afternoon_hours,
         entries: entries[key][:afternoon][:loc2],
         columnoffset: 6,
         rowoffset: 3,
         columnsize: 8,
         rowsize: 2,
         title: "#{key} ~ Afternoon")
  draftit(pdf)
  pdf.start_new_page

end

pdf.render_file 'prawn-0005.pdf'
