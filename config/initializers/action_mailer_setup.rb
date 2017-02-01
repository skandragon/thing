ActionMailer::Base.delivery_method = :smtp # be sure to choose SMTP delivery
ActionMailer::Base.smtp_settings = {
    :address              => "white.flame.org",
    :port                 => 587,
    :domain               => "flame.org",
    :user_name            => MultaArcana::secret_for(:smtp_username),
    :password             => MultaArcana::secret_for(:smtp_password),
    :authentication       => "plain",
    :enable_starttls_auto =>  true,
    :openssl_verify_mode  => 'none',
}
