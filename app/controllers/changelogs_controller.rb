class ChangelogsController < ApplicationController
  def show
    @date = Time.zone.parse(params[:id])
    @changelog = Changelog.changes_since
  end
end
