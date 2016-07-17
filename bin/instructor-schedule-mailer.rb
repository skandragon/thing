instructor_ids = Instructable.pluck(:user_id).uniq.compact

instructors = User.where(id: instructor_ids)

instructors.each do |instructor|
  if instructor.instructables.where(schedule: "Pennsic University").count == 0
    puts "Skipping instructor #{instructor.titled_sca_name} (#{instructor.email}): no instructables"
    next
  end

  InstructorMailer.send_message(instructor, 'Class List').deliver
end
