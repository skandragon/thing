class InstructablesMailer < ActionMailer::Base
  default from: "noreply@pennsicuniversity.org"

  def create(instructable)
    mail(to: instructable.user.email, subject: "Created: #{instructable.subject}")
  end
end
