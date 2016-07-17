instructor_ids = Instructable.pluck(:user_id).uniq.compact

instructors = User.where(id: instructor_ids)

instructors.each do |instructor|
  if instructor.instructables.count == 0
    puts "Skipping instructor #{instructor.name} (#{instructor.email}): no instructables"
    next
  end

  mailer = InstructorMailer.send_message(instructor, 'Class List')
  if instructor.email == 'explorer@flame.org'
    mailer.deliver
  end
end
