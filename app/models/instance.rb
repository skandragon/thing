# == Schema Information
#
# Table name: instances
#
#  id              :integer          not null, primary key
#  instructable_id :integer
#  start_time      :datetime
#  end_time        :datetime
#  location        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Instance < ActiveRecord::Base
  belongs_to :instructable

  after_save :update_instructable

  validates_presence_of :start_time
  validates_presence_of :end_time

  private

  def update_instructable
    instructable.update_scheduled_flag_from_instance
  end
end
