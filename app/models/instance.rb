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
#  year              :integer
#

class Instance < ApplicationRecord
  belongs_to :instructable, touch: true

  has_paper_trail

  default_scope { where(year: 2019) }

  after_save :update_instructable
  before_validation :update_end_time

  validate :validate_start_time

  delegate :topic, to: :instructable
  delegate :titled_sca_name, to: :instructable

  def self.for_date(date)
    not_before = Time.zone.parse(date).utc
    not_after = Time.zone.parse(date).end_of_day.utc
    instances = Instance.where('start_time >= ? AND end_time <= ?', not_before, not_after).order(:location, :start_time).includes(:instructable)
    instances = instances.select { |x| !x.instructable.location_nontrack? }
    instances
  end

  def formatted_location
    if instructable.location_nontrack?
      instructable.formatted_nontrack_location
    else
      location || nil
    end
  end

  def scheduled?
    if instructable.location_nontrack?
      start_time.present?
    else
      start_time.present? and location.present?
    end
  end

  def formatted_start_time(format = :pennsic_short)
    start_time.present? ? start_time.to_s(format) : nil
  end

  def formatted_location_and_time(format = :pennsic_short)
    phrase = format == :pennsic_time_only ? 'at' : 'on'
    loc = formatted_location
    if start_time.present? and loc.present?
      ret = [loc, formatted_start_time(format)].join(" #{phrase} ")
    elsif start_time.present? and loc.blank?
      ret = "Location pending, #{formatted_start_time(format)}"
    elsif start_time.blank? and loc.present?
      ret = "#{loc}, time pending"
    else
      ret = 'Location and time pending'
    end
    ret.gsub(/[\ ]+/, ' ')
  end

  def self.free_busy_report_for(date, track)
    instances = for_date(date)
    locations = Instructable::TRACKS[track]
    grid = make_grid(locations)

    instances.each do |instance|
      x = grid[:xlabels].index(instance.location)
      hour_start = instance.start_time.hour
      hour_end = (instance.end_time - 1).hour
      (hour_start..hour_end).each do |hour|
        y = grid[:ylabels].index('%02d' % hour)
        grid[:grid][y][x] << instance if (x.present? and y.present?)
      end
    end

    grid
  end

  def foo(data)
    if start_time.present?
      self.start_time -= start_time.sec  # remove any seconds
      self.end_time = start_time + data.duration.hours
    end

    if data.location_nontrack?
      self.location = data.formatted_nontrack_location
    end
  end

  def update_end_time
    foo(instructable) if instructable.present?
    true
  end

  private

  def self.make_row(size)
    ret = []
    size.times do
      ret << []
    end
    ret
  end

  def self.make_grid(locations)
    hours = []
    (9..21).each do |hour|
      hours << ('%02d' % hour)
    end
    grid = []
    hours.size.times do
      grid << make_row(locations.size)
    end

    { grid: grid, xlabels: locations, ylabels: hours }
  end

  def validate_start_time
    return if start_time.blank? or override_location?
    unless Instructable::CLASS_DATES.include?(start_time.to_date.to_s)
      errors.add(:start_time, "#{start_time.to_date} is not a class day (#{Instructable::CLASS_DATES.join(', ')})")
    end
  end

  def update_instructable
    instructable.update_scheduled_flag_from_instance if instructable.present?
    true
  end
end
