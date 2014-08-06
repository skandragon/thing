data = []

header = %w(start_time end_time)
User::KINGDOMS.each do |kingdom|
  header << kingdom
end

puts header.join(',')

Instructable::PENNSIC_DATES_RAW.each do |date|
  start_time = Time.parse("#{date}T12:00:00")
  end_time = start_time + 1.day

  instances = Instance.where("start_time >= '#{start_time}' AND start_time < '#{end_time}'")
  instructables = Instructable.where(id: instances.pluck(:instructable_id))
  users = User.where(id: instructables.pluck(:user_id))

  instructables = instructables.group_by { |x| x[:id] }
  users = users.group_by { |x| x[:id] }

  kingdoms = {}
  User::KINGDOMS.each do |kingdom|
    kingdoms[kingdom] = 0
  end

  instances.each do |instance|
    instructable = instructables[instance.instructable_id].first
    user = users[instructable.user_id].first

    kingdoms[user.kingdom] += instructable.duration if user.kingdom.present?
  end

  row = [ start_time, end_time ]
  User::KINGDOMS.each do |kingdom|
    row << kingdoms[kingdom].to_f
  end
  puts row.join(',')
end
