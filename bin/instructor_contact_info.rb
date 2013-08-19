require 'csv'

instructor_ids = Instructable.pluck(:user_id).uniq.compact

instructors = User.where(id: instructor_ids)

CSV.open("instructors_contacts.csv", "wb") do |csv|
  csv << ["InstructorName", "ProfileEmail", "AlternateEmail", "Facebook", "Twitter", "WebPage" ]

  instructors.each do |instructor|
    methods = instructor.instructor_profile_contacts

    profile_email = ""
    alternate_email = ""
    facebook = ""
    twitter = ""
    web_page = ""

    methods.each do |method|
      next if method.address.blank?
      case method.protocol
      when 'profile email'
        if method.address == "1"
          profile_email = instructor.email
        end
      when 'alternate email'
        alternate_email = method.address
      when 'facebook'
        facebook = method.address
      when 'twitter'
        twitter = method.address
      when 'web page'
        web_page = method.address
      end
    end

    csv << [ instructor.best_name, profile_email, alternate_email, facebook, twitter, web_page ]
  end
end
