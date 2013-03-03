class Admin::TrackLeadEmailListController < ApplicationController
  def index
    @email_addresses = []
    User.find_each do |user|
      next unless user.coordinator?
      @email_addresses << user.email
    end
  end
end
