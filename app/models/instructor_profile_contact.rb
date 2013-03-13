# encoding: utf-8
# == Schema Information
#
# Table name: instructor_profile_contacts
#
#  id                    :integer          not null, primary key
#  instructor_profile_id :integer
#  protocol              :string(255)
#  address               :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class InstructorProfileContact < ActiveRecord::Base
  belongs_to :user

  PROTOCOL_TYPES = {
    "profile email" => :email,
    "alternate email" => :email,
    "twitter" => :string,
    "facebook" => :string,
    "web page" => :url,
  }
  PROTOCOLS = PROTOCOL_TYPES.keys
  
  def <=>(other)
    PROTOCOLS.index(protocol) <=> PROTOCOLS.index(other.protocol)
  end
end
