class ChangelogsController < ApplicationController
  def show
    if params[:id].present?
      date = params[:id]
      if date.blank? or date == 'today'
        date = Time.zone.now.strftime('%Y-%m-%d')
      end
      @date = Time.zone.parse(date)
    else
      @date = Time.zone.now unless date
    end
    @changelog = Changelog.changes_since(@date)
  end
end
