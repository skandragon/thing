class Admin::InstructorEmailListController < ApplicationController
  def index
    @email_addresses = User.where(instructor: true).pluck(:email)
  end
end
