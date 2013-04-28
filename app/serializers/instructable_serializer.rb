class InstructableSerializer < ActiveModel::Serializer
  attributes :id, :additional_instructors, :adult_only,
    :camp_address, :camp_name, :created_at,
    :description_book, :description_web, :duration,
    :handout_fee, :handout_limit, :location_type,
    :material_fee, :material_limit,
    :name, :repeat_count, :scheduled,
    :topic, :subtopic, :culture, :track, :updated_at, :user_id,
    :titled_instructor_name

  has_many :instances

  def titled_instructor_name
    object.titled_sca_name
  end
end
