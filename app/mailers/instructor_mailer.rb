class InstructorMailer < ActionMailer::Base
  include GriffinMarkdown

  layout 'email'

  default from: 'noreply@pennsicuniversity.org', css: 'email'

  #
  # Send mail to an instructor, with optional replacable tags for certain
  # functions.
  #
  def send_message(user, subject)
    @user = user
    ids = Instructable.where(user_id: @user.id).pluck(:id)
    @instances = Instance.where(instructable_id: ids).includes(:instructable)
    @name = @user.titled_sca_name

    mail(to: user.email, subject: "Pennsic University: #{subject}")
  end
end
