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
#  name                   :string(255)
#  access_token           :string(255)
#  admin                  :boolean          default(FALSE)
#  coordinator_track      :string(255)
#  pu_staff               :boolean
#


class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  before_validation :generate_access_token

  has_one :instructor_profile, dependent: :destroy
  has_many :instructables, dependent: :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :access_token
  validates_uniqueness_of :access_token

  def generate_access_token
    return unless access_token.blank?

    possible_token = nil
    conflict = true
    while possible_token.blank?
      possible_token = SecureRandom.base64(24)
      u = User.find_by_access_token(possible_token)
      possible_token = nil unless u.nil?
    end
    write_attribute(:access_token, possible_token)
  end

  def instructor?
    instructor_profile.present?
  end

  def coordinator?
    coordinator_track.present?
  end

  def instructables_session_count
    total = instructables.where(location_camp: [false, nil]).pluck(:repeat_count).inject(:+)
    total ||= 0
  end

  def display_name
    ret = ''
    if email.present? && name.blank?
      ret = email
    elsif email.present? && name.present?
      ret = "#{name} (#{email})"
    elsif name.present?
      ret = name
    end
    ret
  end
end
