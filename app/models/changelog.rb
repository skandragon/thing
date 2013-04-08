# encoding: utf-8
# == Schema Information
#
# Table name: changelogs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  model_id   :integer
#  action     :string(255)
#  model_type :string(255)
#  changelog  :text
#  notified   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Changelog < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true

  serialize :changelog, JSON

  def self.build_changes(action, item, user)
    user_id = user.present? ? user.id : nil
    item.valid?  # force validation just to normalize model
    new(action: action, user_id: user_id, target_id: item.id, target_type: item.class.to_s, changelog: sanitize_changes(item.changes))
  end

  def validate_and_save
    return if (action == 'update') and changelog.empty?
    save
  end

  private

  def self.sanitize_changes(list)
    data = list.to_json
    data = JSON::load data
    keys = data.keys
    keys.each do |key|
      data.delete(key) if data[key][0] == data[key][1]
    end
    data
  end
end
