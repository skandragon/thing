class Admin::BackupsController < ApplicationController
  def index
    @backups = Backup.list_backups
  end
  
  # download
  def show
    basename = params[:id].split('/').last + '.zip'  # ensure no directory
    send_file Rails.root.join("tmp", "backup", basename)
  end
  
  # create new one
  def new
    Backup.make_backup
    redirect_to admin_backups_path
  end
end
