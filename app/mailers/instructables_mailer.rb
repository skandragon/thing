class InstructablesMailer < ActionMailer::Base
  layout 'email'

  default from: 'thing@pennsicuniversity.org'
  #, css: 'email'

  #
  # On create, send mail to the user who created it so they know it
  # was added successfully, and send mail to the admin users so they
  # know they have something to do.
  #
  def on_create(instructable, address)
    @instructable = instructable
    if address == @instructable.user.email
      @reason = 'you created this class'
    else
      @reason = 'you are an admin of the system'
    end

    mail(to: address, subject: "Class added: #{@instructable.name}")
  end

  #
  # Send mail when the track changes to the appropriate track coordinators
  #
  def on_track_change
    # XXXMLG implement
  end

  #
  # Send email to track leads consisting of:
  #  Summary statistics about their area
  #  Listing of pending-accept classes
  #  Listing of pending-schedule classes
  #  Listing of fully-scheduled classes
  #  Listing of scheduling conflicts for their area
  #
  def track_status(address, track, instructables)
    @track = track
    @track_classes = instructables
    @unscheduled_classes = @track_classes.select { |instructable| !instructable.scheduled? }
    @conflicts = ConflictCheck.conflicts(track: @track)

    mail(to: address, subject: "Track summary for #{@track}")
  end
end
