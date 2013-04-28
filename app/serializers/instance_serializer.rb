class InstanceSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :start_time, :end_time,
    :instructable_id, :location
end
