class ChangelogsController < ApplicationController
  def show
    @date = Time.parse(params[:id]).in_time_zone
    @changelog = Changelog.changes_since
  end
end
