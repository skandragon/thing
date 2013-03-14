# Fetch all track leads for all tracks, all classes for those tracks,
# and run it all through a mailer.

# If there is no track coordinator, send mail to admin.
admin_users = User.where(admin: true).pluck(:email)

Instructable::TRACKS.keys.each do |track|
  users = User.for_track(track).pluck(:email)
  users = admin_users if users.empty?
  instructables = Instructable.where(track: track)

  users.each do |email|
    begin
      InstructablesMailer.track_status(email, track, instructables).deliver
    rescue Exception => e
      puts "While delivering to #{email}: #{e.to_s}"
    end
  end
end
