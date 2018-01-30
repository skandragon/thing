if ["production", "development"].include?(Rails.env)
  ActionMailer::Base.delivery_method = :smtp # be sure to choose SMTP delivery
else
  ActionMailer::Base.delivery_method = :test
end
