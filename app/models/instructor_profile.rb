# encoding: utf-8
# == Schema Information
#
# Table name: instructor_profiles
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  sca_name            :string(255)
#  sca_title           :string(255)
#  phone_number        :string(255)
#  mundane_name        :string(255)
#  class_limit         :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  kingdom             :string(255)
#  phone_number_onsite :string(255)
#  contact_via         :text
#  no_contact          :boolean          default(FALSE)
#  available_days      :date
#

class InstructorProfile < ActiveRecord::Base
  belongs_to :user
  before_save :default_values
  has_many :instructor_profile_contacts

  accepts_nested_attributes_for :instructor_profile_contacts

  # SCA titles, lowercase.
  # These are currently focused on the British words,
  # although UTF-8 strings for other languages would work.
  TITLES = %w(
    prince princess
    duke duchess
    count countess viscount viscountess
    baron baroness
    master mistress
    lord lady
    sir
    king queen
    thl).sort

  TITLES_FOR_SELECT = proc {
    ret = {}
    TITLES.each do |title|
      display = (title == 'thl') ? 'THL' : title.titleize
      ret[display] = title
    end
    ret
  }

  # SCA kingdoms, lowercase.
  KINGDOMS = [
    "æthelmearc", "ansteorra", "an tir", "artemisia", "atenveldt", "atlantia",
    "caid", "calontir",
    "drachenwald", "ealdormere", "east",
    "gleann abhann",
    "lochac",
    "meridies", "middle",
    "northshield",
    "outlands",
    "trimaris",
    "west",
  ]

  # SCA kingdoms, #titleized.
  KINGDOMS_TITLEIZED = KINGDOMS.map { |x| x.titleize }

  before_validation :compress_available_days

  validates_presence_of :mundane_name
  validates_presence_of :phone_number
  validates_presence_of :sca_name
  validates_length_of :sca_name, :within => 1..30
  validates_inclusion_of :sca_title, in: TITLES, allow_blank: true
  validates_inclusion_of :kingdom, in: KINGDOMS, allow_blank: true

  # If any contact protocols are missing from this profile, add them with
  # default values.  This is called on profile load, prior to presenting
  # a form to edit the profile.
  def add_missing_contacts
    existing_protocols = instructor_profile_contacts.pluck(:protocol) || []
    missing = InstructorProfileContact::PROTOCOLS - existing_protocols
    missing.each do |protocol|
      instructor_profile_contacts.build({ protocol: protocol })
    end
  end

  def titled_sca_name
    [sca_title.present? ? sca_title : nil, sca_name].compact.join(" ")
  end

  private

  def default_values
    self.class_limit ||= 4
  end

  def compress_available_days
    self.available_days ||= []
    self.available_days = available_days.select { |x| x.present? }
  end
end
