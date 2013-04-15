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
#

class Changelog < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true

  serialize :changelog, JSON

  def self.build_changes(action, item, user)
    user_id = user.present? ? user.id : nil
    item.valid?  # force validation just to normalize model
    new(action: action, user_id: user_id, target_id: item.id, target_type: item.class.to_s, changelog: sanitize_changes(recursive_changes(item)))
  end

  def self.recursive_changes(item)
    changes = item.changes.dup
    nested_names = item.nested_attributes_options.keys
    nested_names.each do |nested_name|
      nested_changes = {}
      item.send(nested_name).each do |nested|
        if nested.changed?
          nested_changes[nested.id] = nested.changes
        end
      end
      changes[nested_name] = nested_changes unless nested_changes.keys.empty?
    end
    changes
  end

  def validate_and_save
    return if (action == 'update') and changelog.empty?
    save
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

  def self.decompose(data, prefix = nil)
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

  private

  def self.sanitize_changes(list)
    data = list.to_json
    data = JSON::load data
    keys = data.keys
    keys.each do |key|
      if data[key].is_a?Array
        data.delete(key) if data[key][0] == data[key][1]
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
