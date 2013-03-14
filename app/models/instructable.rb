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
#  handout_fee               :integer
#  material_fee              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  duration                  :float
#  culture                   :string(255)
#  topic                     :string(255)
#  subtopic                  :string(255)
#  description_book          :text
#  camp_name                 :string(255)
#  camp_address              :string(255)
#  camp_reason               :string(255)
#  adult_only                :boolean          default(FALSE)
#  adult_reason              :string(255)
#  fee_itemization           :text
#  repeat_count              :integer          default(0)
#  scheduling_additional     :text
#  special_needs_description :text
#  heat_source               :boolean          default(FALSE)
#  heat_source_description   :text
#  additional_instructors    :string(255)
#  requested_days            :date
#  special_needs             :string(255)
#  requested_times           :string(255)
#  track                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#  location_type             :string(255)      default("track")
#

class Instructable < ActiveRecord::Base
  belongs_to :user
  has_many :instances, dependent: :delete_all, order: 'start_time, location'
  accepts_nested_attributes_for :instances, allow_destroy: true

  delegate :titled_sca_name, to: :user

  PENNSIC_DATES = (Date.parse('2013-07-19')..Date.parse('2013-08-03')).to_a.map(&:to_s)
  CLASS_DATES = (Date.parse('2013-07-23') .. Date.parse('2013-08-01')).to_a.map(&:to_s)
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
    'Dance' => [],
    'Fiber Arts' => %W(Dyeing Lace Needlework Sewing Spinning Weaving),
    'Food Arts' => [ 'Brewing and Vintning', 'Cookery', 'Herbs', 'Research' ],
    'Health and Safety' => [],
    'Heraldry' => [],
    'History' => %W(Research),
    'Language' => %W(Research),
    'Leisure' => %W(Gaming Exercise),
    'Maritime' => [],
    'Martial' => [ 'Archery', 'Historic Combat', 'SCA Combat', 'Thrown Weapons' ],
    'Meetings' => [],
    'Music' => [],
    'Parent/Child' => [],
    'Performing Arts' => %W(Bardic Juggling Theater Instrumental Storytelling),
    'SCA Life' => %W(Court Heraldry Meetings Newcomers Persona),
    'Sciences' => [ 'Astronomy', 'Animals', 'Black Powder', 'Equestrian', 'Gardens', 'Research' ],
    'Scribal Arts' => [ 'Calligraphy', 'Illumination' ],
    'Youth Combat' => [],
    'Other' => [],
  }

  TRACKS = {
    'Pennsic University' => [
      'A&S 1', 'A&S 2', 'A&S 3', 'A&S 4', 'A&S 5', 'A&S 6',
      'A&S 7', 'A&S 8', 'A&S 9', 'A&S 10', 'A&S 11', 'A&S 12',
      'A&S 13', 'A&S 14', 'A&S 15', 'A&S 16', 'Battlefield'
    ],
    'Middle Eastern' => [ 'Touch The Earth', 'Middle Eastern Tent' ],
    'European Dance' => [ 'Dance Tent' ],
    'Games' => [ 'Games Tent' ],
    'Performing Arts' => [
      'Performing Arts Tent', 'New PA Tent', 'Amphetheater'
    ],
    'Cooking Lab' => [ 'Æthelmearc Cooking Lab' ],
    'Æthelmearc Scribal' => ['Æthelmearc 1', 'Æthelmearc 2', 'Æthelmearc 3' ],
    'Heraldry' => ['A&S 2'],
    'Glass' => ['A&S 5'],
    'Thrown Weapons' => ['Thrown Weapons'],
    'Archery' => ['Archery'],
    'Parent/Child' => ['A&S 8'],
    'First Aid' => ['A&S 1'],
    'Bardic' => ['A&S 9'],
    'Music' => ['A&S 9'],
    'Youth Combat' => [ 'Youth Combat' ],
  }

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

  validates_inclusion_of :location_type, :in => [ 'track', 'private-camp', 'merchant-booth' ]
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

  def location_nontrack?
    location_type != 'track'
  end

  def fee_itemization_required?
    handout_fee.present? or material_fee.present?
  end

  def status_message
    return 'Pending Approval' unless approved?
    return 'Pending Scheduling' unless scheduled?
    return 'Approved and Scheduled'
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

  def formatted_culture_and_topic
    [ culture, topic, subtopic ].select(&:present?).join(' : ')
  end

  def formatted_nontrack_location
    raise Exception.new("location_type is 'tract' but no location known") unless location_nontrack?
    if location_type == 'private-camp'
      ret = ['Private Camp:', camp_name]
      ret << "(#{camp_address})" if camp_address.present?
    elsif location_type == 'merchant-booth'
      ret = ['Merchant Booth:', camp_name]
      ret << "(#{camp_address})" if camp_address.present?
    end
    ret.join(" ")
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

    # First, find one or more instances where the start_time is nil
    unused_entries = instances.where("start_time IS NULL AND (location IS NULL OR location='')").limit(overage)
    overage -= unused_entries.size
    unused_entries.destroy_all
    return if overage <= 0

    # Second, drop the ones with an empty start_time alone
    unused_entries = instances.where("start_time IS NULL").limit(overage)
    overage -= unused_entries.size
    unused_entries.destroy_all
    return if overage <= 0

    # lastly, drop the extras, oldest first
    unused_entries = instances.reorder('start_time DESC').limit(overage)
    overage -= unused_entries.size
    unused_entries.destroy_all
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
      self.material_fee = nil if handout_fee.to_f == 0.0
    end
  end
end
