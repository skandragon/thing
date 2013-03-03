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
#  location_camp             :boolean          default(FALSE)
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
#  tract                     :string(255)
#  scheduled                 :boolean          default(FALSE)
#

class Instructable < ActiveRecord::Base
  belongs_to :user
  has_many :instances, dependent: :delete_all, order: 'start_time, location'
  accepts_nested_attributes_for :instances, allow_destroy: true

  PENNSIC_DATES = (Date.parse('2013-07-19 EST')..Date.parse('2013-08-03 EST')).to_a
  CLASS_DATES = (Date.parse('2013-07-23 EST') .. Date.parse('2013-08-01 EST')).to_a
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
    'Other' => [],
  }

  TRACTS = {
    'Pennsic University' => %W(A01 A02 A03 A04),
    'Middle Eastern' => [ 'Touch The Earth', 'Middle Eastern Tent' ],
    'European Dance' => [ 'Dance Tent' ],
    'Games' => [ 'Games Tent' ],
    'Performing Arts' => [ 'Performing Arts Tent', 'New PA Tent', 'Amphetheater' ],
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

  validates_presence_of :camp_name, :if => :location_camp?
  validates_presence_of :camp_reason, :if => :location_camp?

  validates_presence_of :adult_reason, :if => :adult_only?

  validates_presence_of :repeat_count
  validates_numericality_of :repeat_count, greater_than: 0

  validates_presence_of :heat_source_description, :if => :heat_source?

  validates_inclusion_of :culture, :in => CULTURES, allow_blank: true

  validates_presence_of :topic
  validates_inclusion_of :topic, :in => TOPICS.keys

  validate :validate_subtopic

  before_validation :compress_arrays
  before_save :update_scheduled_flag

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

  def update_scheduled_flag_from_instance
    update_column(:scheduled, fully_scheduled?)
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
    for instance in instances
      if location_camp?
        scheduled_instances += 1 if instance.start_time.present?
      else
        scheduled_instances += 1 if instance.start_time.present? and instance.location.present?
      end
    end
    scheduled_instances
  end

  def fully_scheduled?
    scheduled_instance_count >= repeat_count
  end

  def update_scheduled_flag
    write_attribute(:scheduled, fully_scheduled?)
    true
  end

  def compress_arrays
    self.requested_days ||= []
    self.requested_days = requested_days.select { |x| x.present? }

    self.requested_times ||= []
    self.requested_times = requested_times.select { |x| x.present? }

    self.special_needs ||= []
    self.special_needs = special_needs.select { |x| x.present? }
  end
end
