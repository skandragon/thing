class ChangelogsController < ApplicationController
  def show
    if params[:id].present?
      date = params[:id]
      if date.blank? or date == 'today'
        date = Time.zone.now.strftime('%Y-%m-%d')
      end
      @date = Time.zone.parse(date)
    else
      @date = Time.zone.now unless date
    end

    filename = "pennsic-#{Schedule::PENNSIC_YEAR}-all.csv"
    cache_filename = Rails.root.join('tmp', filename)

    load_data
    renderer = CalendarRenderer.new(@instances, nil)
    data = renderer.render_csv({}, "pennsic-#{Schedule::PENNSIC_YEAR}-full.csv")
    cache_in_file(cache_filename, data)

    @changes = CsvCompare.new(cache_filename)
    @changes.filter_for_date(@date)
  end

  private

  def load_data
    @instances = Instance.order('start_time, btrsort(location)').includes(instructable: [:user])
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
end
