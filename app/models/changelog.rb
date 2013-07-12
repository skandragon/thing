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
#

class Changelog < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true

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

  def self.recursive_flarg(item)
    item.each do |field, changes|
      if changes.is_a?Array and changes[0].is_a?Hash
        changes.each do |item|
          puts "#{item}"
          recursive_flarg(item, field)
        end
      else
        puts "#{field}: #{changes[0]} -> #{changes[1]}"
      end
    end
  end

  def self.flarg(target_class, timestamp)
    changelogs = Changelog.
      where(target_type: target_class).
      where('created_at >= ?', timestamp).
      order(:created_at)

    changelogs.each do |cl|
      recursive_flarg(cl.changelog)
    end

    nil
  end

  def self.instance_changes(original, current)
    ret = { id: original.id }

    %w( location start_time end_time ).each do |field|
      if original[field] != current[field]
        ret[field] = [ original[field], current[field] ]
      end
    end

    ret
  end

  def self.changes_for_instances(original, current)
    original_ids = original.map(&:id)
    current_ids = current.map(&:id)
    ret = {}

    shared_ids = original_ids & current_ids
    deleted_ids = original_ids - shared_ids
    added_ids = current_ids - shared_ids

    deleted_ids.each do |id|
      ret[:deleted] ||= []
      ret[:deleted] << original.select { |x| x.id == id }.first
    end

    added_ids.each do |id|
      ret[:added] ||= []
      ret[:added] << current.select { |x| x.id == id }.first
    end

    shared_ids.each do |id|
      oi = original.select { |x| x.id == id }.first
      ci = current.select { |x| x.id == id }.first

      delta = instance_changes(oi, ci)
      ret[id] = delta unless delta.blank?
    end

    ret
  end

  def self.changes_for(list)
    original = Hashie::Mash.new(list[0])
    current = Hashie::Mash.new(list[1])
    ret = { id: original.id }

    %w( name material_limit handout_limit description_web description_book handout_fee material_fee duration culture topic subtopic adult_only fee_itemization track ).each do |field|
      if original[field] != current[field]
        ret[field] = [ original[field], current[field] ]
      end
    end

    ret[:instances] = changes_for_instances(original['instances'], current['instances'])

    Hashie::Mash.new(ret)
  end

  def self.changes_since(date = Date.parse('20130511T075500Z'))
    changes = Changelog.where(target_type: "Instructable").where('created_at >= ?', date).where('original is not null').order(:created_at).group_by(&:target_id)

    ret = []
    changes.each do |key, changelist|
      ret << changes_for(split_by_date(changelist, date))
    end

    ret
  end

  def self.split_by_date(logs, date)
    logs = logs.sort { |a, b| a.created_at <=> b.created_at }
    [ logs.first.original, logs.last.committed ]
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
