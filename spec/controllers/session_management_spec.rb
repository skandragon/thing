require 'spec_helper'

def attempt_sign_up(args)
  visit new_user_registration_path
  args.keys.each { |field|
    find('#user_' + field.to_s).set args[field]
  }
  click_button 'Sign up'
end

describe Users::RegistrationsController do
  describe 'sign up' do
    it 'works with email, password, and password confirmation' do
      attempt_sign_up email: 'example@example.com', password: 'secret123', password_confirmation: 'secret123'
      page.should have_content 'Welcome! You have signed up successfully.'
      page.should have_content 'Become an instructor'
    end

    it 'fails without email' do
      attempt_sign_up password: 'secret123', password_confirmation: 'secret123'
      page.should_not have_content 'Welcome'
    end

    it 'fails without password' do
      attempt_sign_up email: 'example@example.com', password_confirmation: 'secret123'
      page.should_not have_content 'Welcome'
    end

    it 'fails without password_confirmation' do
      attempt_sign_up email: 'example@example.com', password: 'secret123'
      page.should_not have_content 'Welcome'
    end

    it 'fails without matching password and password_confirmation' do
      attempt_sign_up email: 'example@example.com', password: 'SeCreT123', password_confirmation: 'secret123'
      page.should_not have_content 'Welcome'
    end
  end

  describe 'sign in' do
    it 'works with a valid email and password' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'secret123'
      click_button 'Sign in'
      page.should have_content 'Signed in successfully.'
    end

    it 'fails with a valid email but bad password' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'elsewhere'
      click_button 'Sign in'
      page.should have_content 'Invalid email or password.'
    end

    it 'fails with a valid email but bad password' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'elsewhere'
      click_button 'Sign in'
      page.should have_content 'Invalid email or password.'
    end

    it 'fails with an invalid email' do
      visit new_user_session_path
      fill_in 'Email', with: 'whatever@example.com'
      fill_in 'Password', with: 'elsewhere'
      click_button 'Sign in'
      page.should have_content 'Invalid email or password.'
    end

  end

  describe 'sign out' do
    it 'works' do
      log_in
      click_on 'Sign out'
      page.should have_content 'Signed out successfully.'
    end
  end

  describe 'change password' do
    before :each do
      log_in password: 'abc123'
      visit edit_user_registration_path
    end

    it 'changes when current password matches' do
      fill_in 'Current password', with: 'abc123'
      first('#user_password').set 'flarg123'
      fill_in 'Password confirmation', with: 'flarg123'
      within '#submit' do
        click_button 'Update Profile'
      end
      page.should have_content 'You updated your account successfully.'
    end

    it 'will not change when the current password is not provided' do
      within '#submit' do
        click_button 'Update Profile'
      end
      page.should have_content "can't be blank"
    end

    it 'will not change when the current password is incorrect' do
      fill_in 'Current password', with: 'flarg'
      within '#submit' do
        click_button 'Update Profile'
      end
      page.should have_content 'is invalid'
    end

    it 'will not change when the confirmation is wrong' do
      fill_in 'Current password', with: 'abc123'
      first('#user_password').set 'flarg123'
      fill_in 'Password confirmation', with: 'flarg321'
      within '#submit' do
        click_button 'Update Profile'
      end
      page.should have_content "doesn't match confirmation"
    end
  end

  describe 'recover password' do
    it 'fails for empty email addresses' do
      visit new_user_password_path
      click_on 'Send me reset password instructions'
      page.should have_content "can't be blank"
    end

    it 'fails for unknown email addresses' do
      visit new_user_password_path
      fill_in 'Email', with: 'nouser@example.com'
      click_on 'Send me reset password instructions'
      page.should have_content 'not found'
    end

    it 'works for a real user' do
      user = create(:user)
      visit new_user_password_path
      fill_in 'Email', with: user.email
      click_on 'Send me reset password instructions'
      page.should have_content 'You will receive an email with instructions about how to reset your password in a few minutes.'
    end
  end
end