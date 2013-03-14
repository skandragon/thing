# encoding: utf-8
# == Schema Information
#
# Table name: instances
#
#  id                :integer          not null, primary key
#  instructable_id   :integer
#  start_time        :datetime
#  end_time          :datetime
#  location          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  override_location :boolean
#

class Instance < ActiveRecord::Base
  belongs_to :instructable, touch: true

  after_save :update_instructable
  before_validation :update_end_time

  validate :validate_start_time

  def formatted_location
    if instructable.location_nontrack?
      return instructable.formatted_nontrack_location
    else
      return location
    end
  end

  def scheduled?
    if instructable.location_nontrack?
      start_time.present?
    else
      start_time.present? and location.present?
    end
  end

  def formatted_start_time
    start_time.present? ? start_time.to_s(:pennsic_short) : nil
  end

  def formatted_location_and_time
    [formatted_location, formatted_start_time].compact.join(" on ")
  end

  private

  def validate_start_time
    return if start_time.blank?
    unless Instructable::CLASS_DATES.include?(start_time.to_date.to_s)
      errors.add(:start_time, start_time.to_s)
      errors.add(:start_time, "#{start_time.to_date} is not a class day (#{Instructable::CLASS_DATES.join(', ')})")
    end
  end

  def update_end_time
    if start_time.present?
      self.start_time -= start_time.sec  # remove any seconds
      if instructable.present?
        self.end_time = start_time + instructable.duration.hours
      end
    end
  end

  def update_instructable
    instructable.update_scheduled_flag_from_instance
  end
end
