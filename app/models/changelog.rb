# encoding: utf-8
# == Schema Information
#
# Table name: changelogs
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  action      :string(255)
#  target_id   :integer
#  target_type :string(255)
#  changelog   :text
#  notified    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  original    :text
#  committed   :text
#  year        :integer
#

class Changelog < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true

  default_scope { where(year: 2019) }

  before_save :abort_if_useless

  serialize :changelog, JSON
  serialize :committed, JSON
  serialize :original, JSON

  def useless?
    action == 'destroy' ? original.blank? : changelog.blank?
  end

  def self.build_changes(action, item, user)
    user_id = user.present? ? user.id : nil
    item.valid?  # force validation just to normalize model
    new(action: action, user_id: user_id, target_id: item.id, target_type: item.class.to_s, changelog: sanitize_changes(recursive_changes(item)), committed: recursive_attributes(item))
  end

  def self.build_destroy(item, user)
    user_id = user.present? ? user.id : nil
    item.valid?  # force validation just to normalize model
    snapshot = recursive_attributes(item)
    new(action: 'destroy', user_id: user_id, target_id: item.id, target_type: item.class.to_s, changelog: nil, original: snapshot)
  end

  def self.build_attributes(item)
    recursive_attributes(item)
  end

  def self.decompose(data)
    ret = {}

    data.each do |field_name, item|
      if item.is_a?Array
        ret[field_name.to_s] = item
      else
        decompose_hash(field_name.to_s, item, ret)
      end
    end
    ret
  end

  def validate_and_save
    return if (action == 'update') and changelog.empty?
    save
  end

  def self.instance_changes(original, current)
    ret = { }

    %w( location start_time end_time ).each do |field|
      a = original[field].to_s.strip.downcase
      b = current[field].to_s.strip.downcase
      if field == 'location'
        a.gsub!(/^camp: /, '')
        b.gsub!(/^camp: /, '')
      end

      if a != b
        ret[field] = [ original[field], current[field] ]
      end
    end

    unless ret.empty?
      ret[:id] = original.id
    end
    ret
  end

  def self.changes_for_instances(original, current)
    original_ids = original.map(&:id)
    current_ids = current.map(&:id)
    ret = []

    shared_ids = original_ids & current_ids
    deleted_ids = original_ids - shared_ids
    added_ids = current_ids - shared_ids

    deleted_ids.each do |id|
      data = original.select { |x| x.id == id }.first
      data[:action] = 'destroy'
      ret << data
    end

    added_ids.each do |id|
      data = current.select { |x| x.id == id }.first
      data[:action] = 'create'
      ret << data
    end

    shared_ids.each do |id|
      oi = original.select { |x| x.id == id }.first
      ci = current.select { |x| x.id == id }.first

      delta = instance_changes(oi, ci)
      unless delta.blank?
        delta[:action] = 'update'
        delta[:original] = oi
        delta[:current] = ci
        ret << delta
      end
    end

    ret
  end

  def self.changes_for(list)
    action = list[0]
    original = Hashie::Mash.new(list[1])
    current = Hashie::Mash.new(list[2])

    case action
    when 'update'
      ret = changes_for_update(original, current)
    when 'destroy'
      ret = changes_for_destroy(original)
    when 'create'
      ret = changes_for_create(original)
    end

    if ret.nil?
      nil
    else
      ret[:action] = action
      ret[:id] = original.id
      Hashie::Mash.new(ret)
    end
  end

  def self.changes_for_destroy(original)
    ret = { class_name: original.name }

    if original.instances.present?
      ret[:instances] = original.instances.map { |i| i.action = 'destroy' ; i }
    end

    ret
  end

  def self.changes_for_create(current)
    ret = { class_name: current.name }

    if current.instances.present?
      ret[:instances] = current.instances.map { |i| i.action = 'create' ; i }
    end

    ret
  end

  def self.changes_for_update(original, current)
    ret = { }

    %w( duration ).each do |field|
      a = original[field].to_s.strip.downcase
      b = current[field].to_s.strip.downcase
      if a != b
        ret[field] = [ original[field], current[field] ]
      end
    end

    instances = changes_for_instances(original['instances'], current['instances'])
    if ret.empty? and instances.empty?
      return nil
    end
    ret[:instances] = instances
    ret[:class_name] = current.name

    ret
  end

  def self.changes_since(date = nil)
    date = Time.zone.parse('20130511T075500Z') if date.blank?

    changes = Changelog.where(target_type: 'Instructable').where('created_at >= ?', date).order(:created_at).group_by(&:target_id)

    ret = []
    changes.each do |key, changelist|
      changelist_filtered = changelist.select { |c|
        (c.action == 'update' and c.original.present?) or
        (c.action == 'destroy' and c.original.present?) or
        (c.action == 'create' and c.committed.present?)
      }
      next if changelist_filtered.empty?

      data = split_by_date(changelist_filtered, date)
      if data.present?
        cf = changes_for(data)
        ret << cf if cf.present?
      end
    end

    ret
  end

  def self.interesting_change(change, start_date, end_date)
    action = change[:action]

    ret = []

    case action
    when 'update'
      if change[:instances].present?
        interesting = change[:instances].select { |i|
          (i.action == 'update'
            ((i.current and i.current.start_time and i.current.start_time >= start_date and i.current.start_time <= end_date) or
             (i.original and i.original.start_time and i.original.start_time >= start_date and i.original.start_time <= end_date))) or
          ((i.action == 'destroy' or i.action == 'create') and
            (i.start_time and i.start_time >= start_date and i.start_time <= end_date))
        }
        ret = [ 'update', change.class_name, interesting ] if interesting.present?
      end
    when 'destroy'
      interesting = change[:instances].select { |i|
        i.start_time and i.start_time >= start_date and i.start_time <= end_date
      }
      ret = [ 'destroy', change.class_name, interesting ] if interesting.present?
    when 'create'
      if change[:instances].present?
        interesting = change[:instances].select { |i|
          (i.start_time) and (i.start_time >= start_date) and (i.start_time <= end_date)
        }
        ret = [ 'create', change.class_name, interesting ] if interesting.present?
      end
    end

    ret
  end

  def self.changes_for_date(changes, date)
    start_date = Time.zone.parse(date).beginning_of_day.iso8601
    end_date = Time.zone.parse(date).end_of_day.iso8601

    ret = []

    changes.each do |change|
      result = interesting_change(change, start_date, end_date)
      ret << result if result.present?
    end

    ret
  end

  def self.split_by_date(logs, date)
    logs = logs.sort { |a, b| a.created_at <=> b.created_at }

    actions = logs.map { |l| l.action }.uniq

    if actions.include?'destroy' and actions.include?'create'
      ret = nil
    elsif actions.include?'destroy'
      ret = [ 'destroy', logs.first.original.present? ? logs.first.original : logs.first.committed ]
    elsif actions.include?'create'
      ret = [ 'create', logs.last.committed ]
    elsif actions == ['update']
      ret = [ 'update', logs.first.original, logs.last.committed ]
    else
      raise Exception.new("Unknown action: #{action}")
    end

    ret
  end

  def generate_differences(a = original, b = committed)
    return [a.class.name, nil] if !a.nil? && b.nil?
    return [nil, b.class.name] if !b.nil? && a.nil?

    differences = {}
    a.each do |k, v|
      if !v.nil? && b[k].nil?
        differences[k] = [v, nil]
        next
      elsif !b[k].nil? && v.nil?
        differences[k] = [nil, b[k]]
        next
      end

      if v.is_a?(Hash)
        unless b[k].is_a?(Hash)
          differences[k] = 'Different types'
          next
        end
        diff = different?(a[k], b[k])
        differences[k] = diff if !diff.nil? && diff.count > 0

      elsif v.is_a?(Array)
        unless b[k].is_a?(Array)
          differences[k] = 'Different types'
          next
        end

        c = 0
        diff = v.map do |n|
          if n.is_a?(Hash)
            diffs = different?(n, b[k][c])
            c += 1
            diffs unless diffs.nil?
          else
            c += 1
            {n: b[c] } unless b[c] == n
          end
        end.compact

        differences[k] = diff if diff.count > 0

      else
        differences[k] = [v, b[k]] unless v == b[k]

      end
    end

    differences if !differences.nil? && differences.count > 0
  end

  private

  def abort_if_useless
    !useless?
  end

  def self.recursive_attributes(item)
    data = item.attributes

    nested_names = item.nested_attributes_options.keys
    nested_names.each do |nested_name|
      data[nested_name.to_s] = item.send(nested_name).map { |x| recursive_attributes(x) }
    end
    data
  end

  def self.recursive_changes(item)
    new_counter = 0
    changes = item.changes.dup
    nested_names = item.nested_attributes_options.keys
    nested_names.each do |nested_name|
      nested_changes = {}
      item.send(nested_name).each do |nested|
        if nested.changed?
          nested_id = nested.id
          if nested_id.blank?
            nested_id = "new#{new_counter}"
            new_counter += 1
          end
          nested_changes[nested_id] = nested.changes
        end
      end
      changes[nested_name] = nested_changes unless nested_changes.keys.empty?
    end
    changes
  end

  def self.decompose_hash(field_name, data, ret)
    data.each do |key, item|
      name = "#{field_name}-#{key}"
      if item.is_a?Array
        ret[name] = item
      else
        decompose_hash(name, item, ret)
      end
    end
  end

  def self.identical(a, b)
    a.to_s.strip == b.to_s.strip
  end

  def self.sanitize_changes(list)
    data = JSON::load list.to_json
    keys = data.keys
    keys.each do |key|
      if data[key].is_a?Array
        data.delete(key) if identical(data[key][0], data[key][1])
      else
        new_data = sanitize_changes(data[key])
        if new_data.empty?
          data.delete(key)
        else
          data[key] = new_data
        end
      end
    end
    data
  end
end
