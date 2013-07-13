class ChangelogsController < ApplicationController
  def index
    @changelog = Changelog.changes_since
  end
end
