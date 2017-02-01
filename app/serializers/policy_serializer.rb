class PolicySerializer < ActiveModel::Serializer
  attributes :id, :area, :user_id, :accepted_on, :version, :mailed_on
end
