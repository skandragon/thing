class InstructorMailer < ActionMailer::Base
  include GriffinMarkdown

  default from: 'noreply@pennsicuniversity.org'

  #
  # Send mail to an instructor, with optional replacable tags for certain
  # functions.
  #
  def send_message(user, subject, text)
    @user = user
    ids = Instructable.where(user_id: @user.id).pluck(:id)
    @instances = Instance.where(instructable_id: ids).includes(:instructable)

    @text = replace_tokens(markdown_html(text))
    mail(to: user.email, subject: "Pennsic University: #{subject}")
  end

  private

  def replace_tokens(text)
    text.gsub('@name@', helpers.escape_html(@user.titled_sca_name)).html_safe
  end
end
