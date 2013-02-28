class Admin::InstructorEmailListController < ApplicationController
  def index
    @email_addresses = User.joins(:instructor_profile).pluck(:email)
  end
end
