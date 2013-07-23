require 'csv'

class CsvCompare
  attr_reader :deleted_instances
  attr_reader :created_instances
  attr_reader :changed_instances

  def deleted_instances_for_date
    @deleted_instances_for_date.sort { |a, b|
      ret = a[:start_time] <=> b[:start_time]
      ret = a[:name] <=> b[:name] if ret == 0
      ret = a[:location] <=> b[:location] if ret == 0
      ret
    }
  end

  def created_instances_for_date
    @created_instances_for_date.sort { |a, b|
      ret = a[:start_time] <=> b[:start_time]
      ret = a[:name] <=> b[:name] if ret == 0
      ret = a[:location] <=> b[:location] if ret == 0
      ret
    }
  end

  def changed_instances_for_date
    @changed_instances_for_date.sort { |a, b|
      ret = a[:start_time].last <=> b[:start_time].last
      ret = a[:name] <=> b[:name] if ret == 0
      ret = a[:location].last <=> b[:location].last if ret == 0
      ret
    }
  end

  def initialize(filename)
    @deleted_instances = {}
    @created_instances = {}
    @changed_instances = {}

    @deleted_instances_for_date = []
    @created_instances_for_date = []
    @changed_instances_for_date = []

    book = parse_file('pennsic-42-book.csv')
    now = parse_file(filename)

    compare_all_entries(book, now)

    nil
  end

  def parse_file(filename)
    data = {}

    CSV.foreach(filename, headers: :first_row, return_headers: false) do |row|
      id = row['id'].to_i
      data[id] = {} unless data.has_key?id

      data[id][:name] = row['name']
      data[id][:id] = id
      data[id][:instances] ||= {}
      instance_id = row['instance_id'].to_i
      data[id][:instances][instance_id] = {
        id: instance_id,
        start_time: row['start_time'],
        end_time: row['end_time'],
        location: row['location']
      }
    end

    data
  end

  def compare_entries(one, two)
    if one[:instances] == two[:instances]
      return
    end

    deleted_instances = one[:instances].keys - two[:instances].keys
    created_instances = two[:instances].keys - one[:instances].keys
    in_both = one[:instances].keys & two[:instances].keys

    deleted_instances.each do |id|
      instance = one[:instances][id]
      instance[:name] = one[:name]
      @deleted_instances[id] = instance
    end

    created_instances.each do |id|
      instance = two[:instances][id]
      instance[:name] = two[:name]
      @created_instances[id] = instance
    end

    in_both.each do |id|
      if one[:instances][id] != two[:instances][id]
        @changed_instances[id] = {name: two[:name]}
        [ :location, :start_time, :end_time ].each do |field|
          a = one[:instances][id][field]
          b = two[:instances][id][field]
          @changed_instances[id][field] = [ a, b ]
        end
      end
    end
  end

  def compare_all_entries(book, now)
    deleted_instructables = book.keys - now.keys
    created_instructables = now.keys - book.keys
    in_both = now.keys & book.keys

    in_both.each do |id|
      compare_entries(book[id], now[id])
    end

    deleted_instructables.each do |id|
      instances = book[id][:instances]
      instances.keys.each do |instance_id|
        instance = instances[instance_id]
        instance[:name] = book[id][:name]
        @deleted_instances[instance_id] = instance
      end
    end

    created_instructables.each do |id|
      instances = now[id][:instances]
      instances.keys.each do |instance_id|
        instance = instances[instance_id]
        instance[:name] = now[id][:name]
        @created_instances[instance_id] = instance
      end
    end
  end

  def filter_for_date(date)
    @deleted_instances_for_date = []
    @created_instances_for_date = []
    @changed_instances_for_date = []

    created_instances.each do |id, data|
      if in_time_bracket(date, data[:start_time])
        @created_instances_for_date << data
      end
    end

    deleted_instances.each do |id, data|
      if in_time_bracket(date, data[:start_time])
        @deleted_instances_for_date << data
      end
    end

    changed_instances.each do |id, data|
      if in_time_bracket(date, data[:start_time])
        @changed_instances_for_date << data
      end
    end
  end

  def in_time_bracket(date, list)
    list = Array(list)
    list.each do |target|
      target_time = Time.zone.parse(target).beginning_of_day
      if target_time == date.beginning_of_day
        return true
      end
    end

    false
  end
end
