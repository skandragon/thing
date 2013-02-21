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
#  coordinator_tract      :string(255)
#


class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  before_validation :generate_access_token

  has_one :instructor_profile
  has_many :instructables

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :access_token
  validates_uniqueness_of :access_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name

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
    coordinator_tract.present?
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
