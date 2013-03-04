# encoding: utf-8
# == Schema Information
#
# Table name: instances
#
#  id              :integer          not null, primary key
#  instructable_id :integer
#  start_time      :datetime
#  end_time        :datetime
#  location        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Instance < ActiveRecord::Base
  belongs_to :instructable

  after_save :update_instructable
  before_validation :update_end_time

  def formatted_location_and_time
    [location, start_time.present? ? start_time.to_s(:long) : nil].compact.join(" on ")
  end

  private

  def update_end_time
    if start_time.present?
      self.start_time -= start_time.sec  # remove any seconds
      self.end_time = start_time + (instructable.duration * 3600) # duration is hours
    end
  end

  def update_instructable
    instructable.update_scheduled_flag_from_instance
  end
end
