ids = []

instructables = Instructable.where(location_type: ['merchant-booth', 'private-camp']).where("camp_name ilike 'touch the earth'")
instructables.each do |instructable|
  instructable.location_type = 'track'
  instructable.save!
  
  instructable.reload

  instructable.instances.each do |instance|
    instance.location = 'Touch The Earth'
    instance.save!
  end

  puts instructable.id
  puts instructable.name
  puts instructable.track
  puts instructable.instances.pluck(:location).join(', ')
  puts
  ids << instructable.id
end

puts ids.join(', ')
