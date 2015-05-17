# encoding: utf-8
# == Schema Information
#
# Table name: instructables
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  approved                  :boolean          default(FALSE)
#  name                      :string(255)
#  material_limit            :integer
#  handout_limit             :integer
#  description_web           :text
#  handout_fee               :float
#  material_fee              :float
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  duration                  :float
#  culture                   :string(255)
#  topic                     :string(255)
#  subtopic                  :string(255)
#  description_book          :text
#  additional_instructors    :string(255)      is an Array
#  camp_name                 :string(255)
#  camp_address              :string(255)
#  camp_reason               :string(255)
#  adult_only                :boolean          default(FALSE)
#  adult_reason              :string(255)
#  fee_itemization           :text
#  requested_days            :date             is an Array
#  repeat_count              :integer          default(0)
#  scheduling_additional     :text
#  special_needs             :string(255)      is an Array
#  special_needs_description :text
#  heat_source               :boolean          default(FALSE)
#  heat_source_description   :text
#  requested_times           :string(255)      is an Array
#  track                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#  location_type             :string(255)      default("track")
#  proofread                 :boolean          default(FALSE)
#  proofread_by              :integer          default([]), is an Array
#  proofreader_comments      :text
#  year                      :integer
#  schedule                  :string(255)
#  info_tag                  :string(255)
#

class Instructable < ActiveRecord::Base
  belongs_to :user
  has_many :instances, dependent: :destroy, order: 'start_time, location'
  has_many :changelogs, as: :target
  accepts_nested_attributes_for :instances, allow_destroy: true

  default_scope :conditions => { year: 2015 }

  has_paper_trail

  delegate :titled_sca_name, to: :user

  PENNSIC_DATES_RAW = (Date.parse('2015-07-24')..Date.parse('2015-08-09')).to_a
  PENNSIC_DATES = PENNSIC_DATES_RAW.map(&:to_s)
  CLASS_DATES = (Date.parse('2015-07-27')..Date.parse('2015-08-07')).to_a.map(&:to_s)
  CLASS_TIMES = [ '9am to Noon', 'Noon to 3pm', '3pm to 6pm', 'After 6pm' ]

  CULTURES = [
    'Multiple Cultures',
    'European',
    'Middle Eastern',
    'Far Eastern',
    'Other',
  ]

  TOPICS = {
    'Clothing' => %W(Accessories Beginner),
    'Crafts' => %W(Beads Metal Books Glass Leather Paper Wood),
    'Court' => [],
    'Dance' => [],
    'Event' => [],
    'Fiber Arts' => %W(Dyeing Lace Needlework Sewing Spinning Weaving),
    'Food Arts' => [ 'Brewing and Vintning', 'Cookery', 'Herbs', 'Research' ],
    'Health and Safety' => [],
    'Heraldry' => [],
    'History' => %W(Research),
    'Language' => %W(Research),
    'Leisure' => %W(Gaming Exercise),
    'Maritime' => [],
    'Martial' => [
      'Archery',
      'Heavy Weapons',
      'Historic Combat',
      'Rapier',
      'SCA Combat',
      'Thrown Weapons',
      'War Points',
    ],
    'Meetings' => [],
    'Parent/Child' => [],
    'Party' => [],
    'Performance' => %w(Bardic Commedia Music Storytelling Theater),
    'Performing Arts and Music' => [ 'Bardic', 'Commedia', 'Instrumental Music', 'Juggling', 'Storytelling', 'Theater', 'Vocal Music' ],
    'SCA Life' => %W(Court Heraldry Meetings Newcomers Persona),
    'Sciences' => [ 'Astronomy', 'Animals', 'Black Powder', 'Equestrian', 'Gardens', 'Research' ],
    'Scribal Arts' => %w(Calligraphy Illumination),
    'Youth Combat' => [],
    'Other' => [],
  }

  TRACKS = {
    'Pennsic University' => [
      'A&S 1', 'A&S 2', 'A&S 3', 'A&S 4', 'A&S 5', 'A&S 6',
      'A&S 7', 'A&S 8', 'A&S 9', 'A&S 10', 'A&S 11', 'A&S 12',
      'A&S 13', 'A&S 14', 'A&S 15', 'A&S 16', 'A&S 17', 'Battlefield'
    ],
    'Middle Eastern' => [ 'Touch The Earth', 'Middle Eastern Tent' ],
    'European Dance' => [ 'Dance Tent' ],
    'Games' => [ 'Games Tent' ],
    'Performing Arts and Music' => [ 'Amphitheater', 'Performing Arts Tent', 'Performing Arts Rehearsal Tent', 'A&S 9' ],
    'Cooking Lab' => [ 'Æthelmearc Cooking Lab' ],
    'Æthelmearc Scribal' => ['Æthelmearc 1', 'Æthelmearc 2', 'Æthelmearc 3' ],
    'Heraldry' => ['A&S 2'],
    'Glass' => ['A&S 4'],
    'Thrown Weapons' => [ 'Thrown Weapons Range', 'Thrown Weapons Tent' ],
    'Archery' => [
      'Archery',
      'Archery Tent',
      'Family Range',
      'General Archery',
      'Novelty Range'
    ],
    'Parent/Child' => ['A&S 6'],
    'First Aid' => ['A&S 14'],
    'Youth Combat' => [ 'Youth Combat List' ],
    'In Persona' => [ 'A&S 1' ],
    'Martial Activities' => [
      'Battlefield List',
      'Blue List',
      'East Battlefield',
      'Fort',
      'Green List',
      'Gunnery Point',
      'Inspection Point',
      'Main Battlefield',
      "Marshal's Point",
      'North Battlefield',
      'Red List',
      'South Battlefield',
      'West Battlefield',
      'White List',
    ],
    'Rapier Activities' => [
      'Rapier List 1', 'Rapier List 2', 'Rapier Field', 'Rapier Tent',
      'Rapier Youth List',
    ],
    'Party' => ['Battlefield', 'Great Hall', 'Rune Stone Park'],
    'Court' => ['Great Hall'],
    'Event' => ['Great Hall', 'Rune Stone Park'],
    "Artisan's Row" => [
      "Artisan's Row A",
      "Artisan's Row B",
      "Artisan's Row C"
    ],
    'Youth Point' => [ 'Youth Point' ],
  }

  SCHEDULES = [
      'Pennsic University',
      'War Point',
      "Artisan's Row",
      'Court',
      'Event',
      'Party',
      'Battlefield',
      'Performances',
  ]

  def topic=(value)
    write_attribute(:topic, value)
    write_attribute(:info_tag, nil)
  end

  def self.all_locations
    TRACKS.values.flatten.uniq
  end

  def self.locations(filter = nil)
    filter = Array(filter) unless filter.nil?
    ret = {}
    TRACKS.each do |track, locations|
      if filter.nil? or filter.include?(track)
        locations.each do |location|
          ret[location] ||= []
          ret[location] << track
        end
      end
    end
    ret
  end

  validates_presence_of :name
  validates_length_of :name, :within => 3..50

  validates_presence_of :description_book
  validates_length_of :description_book, :within => 10..150

  validates_presence_of :duration
  validates_numericality_of :duration, greater_than: 0

  validates_numericality_of :handout_limit, greater_than: 0, allow_blank: true, only_integer: true
  validates_numericality_of :handout_fee, greater_than: 0, allow_blank: true

  validates_numericality_of :material_limit, greater_than: 0, allow_blank: true, only_integer: true
  validates_numericality_of :material_fee, greater_than: 0, allow_blank: true

  validates_presence_of :fee_itemization, :if => :fee_itemization_required?

  validates_inclusion_of :location_type, :in => %w(track private-camp merchant-booth)
  validates_presence_of :camp_name, :if => :location_nontrack?
  validates_presence_of :camp_reason, :if => :location_nontrack?

  validates_presence_of :adult_reason, :if => :adult_only?

  validates_presence_of :repeat_count
  validates_numericality_of :repeat_count, greater_than: 0

  validates_presence_of :heat_source_description, :if => :heat_source?

  validates_inclusion_of :culture, :in => CULTURES, allow_blank: true

  validates_presence_of :topic
  validates_inclusion_of :topic, :in => TOPICS.keys

  validate :validate_subtopic

  before_validation :compress_arrays
  before_validation :check_fees_for_zero
  before_validation :set_default_track, on: :create
  before_save :update_scheduled_flag
  after_save :adjust_instances
  after_save :check_for_proofread_changes

  scope :search_by_name, ->(target) {
    where('name ILIKE ?', "%#{target.strip}%")
  }

  scope :for_date, ->(date) {
    target_date = Time.zone.parse(date.to_s)
    joins(:instances).where("instances.start_time >= ? and instances.start_time <= ?",
                            target_date.beginning_of_day, target_date.end_of_day)
  }

  def instructor_kingdom
    user.kingdom
  end

  def is_proofreader=(value)
    @is_proofreader = value
  end

  PROOFREADER_FIELDS = [
    :description_web, :description_book, :name,
    :camp_name, :camp_address,
    :culture, :topic, :subtopic,
    :handout_fee, :handout_limit,
    :material_fee, :material_limit,
    :fee_itemization,
  ]

  def location_nontrack?
    location_type != 'track'
  end

  def fee_itemization_required?
    return true if handout_fee.present?
    return true if material_fee.present?
    false
  end

  def status_message
    return 'Pending Approval' unless approved?
    return 'Pending Scheduling' unless scheduled?
    'Approved and Scheduled'
  end

  def topic_and_subtopic
    ret = [ topic ]
    ret << subtopic if subtopic.present?
    ret.join(' : ')
  end

  def additional_instructors_expanded
    self.additional_instructors ||= []
    additional_instructors.join(', ')
  end

  def additional_instructors_expanded=(value)
    items = value.split(',')
    items = items.map { |item| item.strip }
    self.additional_instructors = items.compact
  end

  def formatted_topic
    [ topic, subtopic ].select(&:present?).join(': ')
  end

  def formatted_culture_and_topic
    [culture, formatted_topic].select(&:present?).join(': ')
  end

  def formatted_nontrack_location
    raise Exception.new("location_type is 'track' but no location known") unless location_nontrack?
    if location_type == 'private-camp'
      ret = [camp_name]
      ret << "(#{camp_address})" if camp_address.present?
    elsif location_type == 'merchant-booth'
      ret = [camp_name]
      ret << "(#{camp_address})" if camp_address.present?
    end
    ret.join(' ')
  end

  def update_scheduled_flag_from_instance
    update_column(:scheduled, fully_scheduled?)

    if fully_scheduled? or partially_scheduled?
      update_column(:approved, true)
    end
  end

  def cleanup_unneeded_instances
    overage = instances.count - repeat_count
    return if overage <= 0

    # First, find one or more instances where the start_time and location is nil
    unused_entries = instances.where("start_time IS NULL AND (location IS NULL OR location='')").limit(overage)
    overage -= unused_entries.size
    unused_entries.destroy_all
    return if overage <= 0

    # Second, drop the ones with an empty start_time alone
    unused_entries = instances.where('start_time IS NULL').limit(overage)
    overage -= unused_entries.size
    unused_entries.destroy_all
    return if overage <= 0

    # lastly, drop the extras, oldest first
    unused_entries = instances.reorder('start_time DESC').limit(overage)
    unused_entries.destroy_all
  end

  def adjust_instances
    instances.each do |instance|
      if instance.start_time.present?
        instance.end_time = instance.start_time + duration.hours
      end
      if location_nontrack?
        instance.location = formatted_nontrack_location
      end
      instance.save(validate: false)
    end
  end

  private

  def validate_subtopic
    if topic.present? and subtopic.present?
      choices = TOPICS[topic]
      if choices.present? and !choices.include?(subtopic)
        errors.add(:subtopic, 'is not a valid subtopic')
      end
    end
  end

  def scheduled_instance_count
    scheduled_instances = 0
    instances.each do |instance|
      scheduled_instances += 1 if instance.scheduled?
    end
    scheduled_instances
  end

  def fully_scheduled?
    scheduled_instance_count >= repeat_count
  end

  def partially_scheduled?
    scheduled_instance_count > 0
  end

  def update_scheduled_flag
    write_attribute(:scheduled, fully_scheduled?)
    true
  end

  def set_default_track
    self.track ||= 'Pennsic University'
  end

  def compress_arrays
    self.requested_days ||= []
    self.requested_days = requested_days.select { |x| x.present? }

    self.requested_times ||= []
    self.requested_times = requested_times.select { |x| x.present? }

    self.special_needs ||= []
    self.special_needs = special_needs.select { |x| x.present? }
  end

  def check_fees_for_zero
    if handout_fee.present?
      self.handout_fee = nil if handout_fee.to_f == 0.0
    end
    if material_fee.present?
      self.material_fee = nil if material_fee.to_f == 0.0
    end
  end

  def check_for_proofread_changes
    return true if @is_proofreader and @is_proofreader == :no_really

    needs_clearing = false
    changes.keys.each do |field_name|
      data = changes[field_name]
      next if data[0].blank? and data[1].blank?
      if data[0].present? and data[1].present?
        next if data[0].to_s.strip == data[1].to_s.strip
      end
      if PROOFREADER_FIELDS.include?(field_name.to_sym)
        needs_clearing = true
      end
    end

    if @is_proofreader
      if proofread_by == [ @is_proofreader ]
        # they are the only proofreader.  Ensure the flag is clear, but
        # don't change the proofread_by list.
        update_column(:proofread, false) if proofread
      else
        # they are the first proofreader, or they are not the only
        # proofreader.
        if needs_clearing
          update_column(:proofread, false) if proofread
          update_column(:proofread_by, [ @is_proofreader ])
        else
          update_column(:proofread_by, (proofread_by + [ @is_proofreader ]).uniq)
          if proofread_by.size >= 2
            update_column(:proofread, true) unless proofread
          end
        end
      end
    elsif needs_clearing
      update_column(:proofread, false) if proofread
      update_column(:proofread_by, []) unless proofread_by.empty?
    end
  end
  true
end
