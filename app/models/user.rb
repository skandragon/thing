# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  mundane_name           :string(255)
#  access_token           :string(255)
#  admin                  :boolean          default(FALSE)
#  pu_staff               :boolean
#  tracks                 :string(255)      default([])
#  sca_name               :string(255)
#  sca_title              :string(255)
#  phone_number           :string(255)
#  class_limit            :integer
#  kingdom                :string(255)
#  phone_number_onsite    :string(255)
#  contact_via            :text
#  no_contact             :boolean          default(FALSE)
#  available_days         :date
#  instructor             :boolean          default(FALSE)
#  proofreader            :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_paper_trail

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

  # SCA kingdoms, lowercase.
  KINGDOMS = [
    'æthelmearc', 'ansteorra', 'an tir', 'artemisia', 'atenveldt', 'atlantia',
    'caid', 'calontir',
    'drachenwald', 'ealdormere', 'east',
    'gleann abhann',
    'lochac',
    'meridies', 'middle',
    'northshield',
    'outlands',
    'trimaris',
    'west',
  ]

  # SCA kingdoms, #titleized.
  KINGDOMS_TITLEIZED = KINGDOMS.map(&:titleize)

  before_save :default_values
  before_validation :generate_access_token, on: :create
  before_validation :compress_tracks
  before_validation :compress_available_days

  has_many :instructables, dependent: :destroy
  has_many :instructor_profile_contacts
  has_many :changelogs # do not delete changelogs!
  has_one :schedule, dependent: :destroy

  accepts_nested_attributes_for :instructor_profile_contacts

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :access_token, on: :create
  validates_uniqueness_of :access_token, on: :create

  validates_presence_of :mundane_name, :if => :instructor?
  validates_presence_of :phone_number, :if => :instructor?
  validates_presence_of :sca_name, :if => :instructor?
  validates_length_of :sca_name, :within => 1..30, :if => :instructor?
  validates_inclusion_of :sca_title, in: TITLES, allow_blank: true
  validates_inclusion_of :kingdom, in: KINGDOMS, allow_blank: true

  scope :for_track, lambda { |track| where('tracks && ?', "{#{track}}") }

  def coordinator?
    tracks.count > 0
  end

  def allowed_tracks
    if admin?
      ['No Track'] + Instructable::TRACKS.keys.sort
    else
      tracks
    end
  end

  def instructables_session_count
    total = instructables.where(location_type: 'track').pluck(:repeat_count).inject(:+)
    total ||= 0
    total
  end

  def display_name
    ret = ''
    if email.present? && mundane_name.blank?
      ret = email
    elsif email.present? && mundane_name.present?
      ret = "#{mundane_name} (#{email})"
    elsif mundane_name.present?
      ret = mundane_name
    end
    ret
  end

  def titled_sca_name
    [sca_title.present? ? sca_title.titleize : nil, sca_name].compact.join(' ')
  end

  def best_name
    if instructor?
      titled_sca_name
    else
      mundane_name
    end
  end

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

  #
  # Return a list of roles.
  #
  def display_roles
    roles = []
    roles << 'Instructor' if instructor?
    roles << 'Coordinator' if coordinator?
    roles << 'Admin' if admin?
    roles << 'Proofreader' if proofreader?
    roles << 'PU Staff' if pu_staff?
    roles
  end

  private

  def generate_access_token
    return unless access_token.blank?

    possible_token = nil
    while possible_token.blank?
      possible_token = SecureRandom.base64(24)
      u = User.find_by_access_token(possible_token)
      possible_token = nil unless u.nil?
    end
    write_attribute(:access_token, possible_token)
  end

  def default_values
    self.class_limit ||= 4
  end

  def compress_tracks
    self.tracks ||= []
    self.tracks = tracks.select { |x| x.present? }.sort
  end

  def compress_available_days
    self.available_days ||= []
    self.available_days = available_days.select { |x| x.present? }
  end
end
