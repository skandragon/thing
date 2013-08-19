require 'csv'

instructor_ids = Instructable.pluck(:user_id).uniq.compact

instructors = User.where(id: instructor_ids)

CSV.open("instructors_and_emails.csv", "wb") do |csv|
  csv << ["InstructorName", "Email", "Class Name"]

  instructors.each do |instructor|
    names = instructor.instructables.pluck(:name)

    names.each do |name|
      csv << [ instructor.best_name, instructor.email, name ]
    end
  end
end
