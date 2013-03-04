class InstructablesMailer < ActionMailer::Base
  default from: "noreply@pennsicuniversity.org"

  #
  # On create, send mail to the user who created it so they know it
  # was added successfully, and send mail to the admin users so they
  # know they have something to do.
  #
  def on_create(instructable, address)
    @instructable = instructable
    if address == @instructable.user.email
      @reason = "you created this class"
    else
      @reason = "you are an admin of the system"
    end

    mail(to: address, subject: "Class added: #{@instructable.name}")
  end

  #
  # Send mail when the track changes to the appropriate track coordinators
  #
  def on_track_change
    # XXXMLG implement
  end
end
