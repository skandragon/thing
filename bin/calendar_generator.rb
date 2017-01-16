
def render_ics
  filename = "pennsic-#{Schedule::PENNSIC_YEAR}-all.ics"
  cache_filename = Rails.root.join('tmp', filename)

  render_options = {}
  render_options[:calendar_name] = "PennsicU #{Schedule::PENNSIC_YEAR}"

  renderer = CalendarRenderer.new(@instances, @instructables)
  data = renderer.render_ics(render_options, filename, cache_filename)
  cache_in_file(cache_filename, data)
end

def render_pdf(omit_descriptions, no_page_numbers)
  filename = [
    "pennsic-#{Schedule::PENNSIC_YEAR}-all",
    omit_descriptions ? 'brief' : nil,
    no_page_numbers ? 'unnumbered' : nil,
  ].compact.join('-') + '.pdf'
  cache_filename = Rails.root.join('tmp', filename)

  render_options = {}
  render_options[:omit_descriptions] = omit_descriptions
  render_options[:no_long_descriptions] = true
  render_options[:no_page_numbers] = no_page_numbers

  renderer = CalendarRenderer.new(@instances, @instructables)
  data = renderer.render_pdf(render_options, filename, cache_filename)
  cache_in_file(cache_filename, data)
end


def render_csv
  filename = "pennsic-#{Schedule::PENNSIC_YEAR}-all.csv"
  cache_filename = Rails.root.join('tmp', filename)

  render_options = {}

  renderer = CalendarRenderer.new(@instances, @instructables)
  data = renderer.render_csv(render_options, "pennsic-#{Schedule::PENNSIC_YEAR}-all.csv")
  cache_in_file(cache_filename, data)
end

def render_xlsx
  filename = "pennsic-#{Schedule::PENNSIC_YEAR}-all.xlsx"
  cache_filename = Rails.root.join('tmp', filename)

  render_options = {}

  renderer = CalendarRenderer.new(@instances, @instructables)
  data = renderer.render_xlsx(render_options, "pennsic-#{Schedule::PENNSIC_YEAR}-all.xlsx")
  cache_in_file(cache_filename, data)
end

def load_data
  @instructables = Instructable.where(scheduled: true).order(:topic, :subtopic, :culture, :name).includes(:instances, :user)
  @instances = Instance.where(instructable_id: @instructables.map(&:id)).order('start_time, btrsort(location)').includes(instructable: [:user])
end

def cache_in_file(cache_filename, data)
  if cache_filename
    tmp_filename = [cache_filename, SecureRandom.hex(16)].join
    File.open(tmp_filename, 'wb') do |f|
      f.write data
    end
    File.rename(tmp_filename, cache_filename)
  end
end

def get_updated_at
  sha1 = Digest::SHA1.new

  sha1 << Instance.order('updated_at DESC').limit(1).pluck(:updated_at).first.to_s
  sha1 << Instructable.order('updated_at DESC').limit(1).pluck(:updated_at).first.to_s
  sha1 << User.select('sca_name, sca_title').map { |a| a.titled_sca_name }.select(&:present?).sort.to_s

  sha1.hexdigest
end

last_date = nil

while true
  current_date = get_updated_at
  if (last_date != current_date) or !File.exists?("tmp/pennsic-#{Schedule::PENNSIC_YEAR}-all.csv")
    last_date = current_date

    puts "#{Time.now} - Generating..."

    load_data

    render_csv
    render_ics
    render_xlsx
    render_pdf(false, false)
    render_pdf(true, false)
    render_pdf(false, true)
    render_pdf(true, true)

    puts "#{Time.now} - Done."
  end

  sleep 60
end
