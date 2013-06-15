module AuthMacros
  def log_in(attributes = {})
    if attributes[:instructor]
      @_current_user = create(:instructor, attributes)
    else
      @_current_user = create(:user, attributes)
    end

    visit new_user_session_path
    page.should have_content 'Remember me'

    fill_in 'Email', with: @_current_user.email
    fill_in 'Password', with: @_current_user.password
    click_button 'Sign in'
    page.should have_content 'Signed in successfully'
  end

  def current_user
    @_current_user
  end
end
