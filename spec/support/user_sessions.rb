module AuthMacros
  def log_in(attributes = {})
    @_current_user = create(:user, attributes)
    visit new_user_session_path
    fill_in "Email", with: @_current_user.email
    fill_in "Password", with: @_current_user.password
    click_button "Sign in"
    page.should have_content "Signed in successfully"
  end

  def current_user
    @_current_user
  end
end
