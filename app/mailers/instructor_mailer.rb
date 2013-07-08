class InstructorMailer < ActionMailer::Base
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
  
  def helpers
    @helper ||= Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    include MarkdownHelper
  end

  def markdown_html(text, options = {})
    helpers.markdown_html(text, options)
  end
  
  def replace_tokens(text)
    text.gsub('@name@', helpers.escape_html(@user.titled_sca_name)).html_safe
  end
end
