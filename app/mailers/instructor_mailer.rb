class InstructorMailer < ActionMailer::Base
  include GriffinMarkdown

  layout 'email'

  default from: 'thing@pennsicuniversity.org', css: 'email'

  #
  # Send mail to an instructor, with optional replacable tags for certain
  # functions.
  #
  def send_message(user, subject)
    @user = user
    ids = Instructable.where(user_id: @user.id, schedule: 'Pennsic University').pluck(:id)
    @instances = Instance.where(instructable_id: ids).includes(:instructable).order(:start_time)
    @name = @user.titled_sca_name

    headers 'return-path' => 'thing@pennsicuniversity.org'

    mail(to: user.email, subject: "Pennsic University: #{subject}")
  end
end
