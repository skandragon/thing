class Admin::InstructorEmailListController < ApplicationController
  def index
    @emailAddresses = User.joins(:instructor_profile).pluck(:email)
  end
end
