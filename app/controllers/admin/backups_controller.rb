class Admin::BackupsController < ApplicationController
  def index
    @backups = Backup.new.list_backup_files
  end

  # download
  def show
    basename = params[:id].split('/').last + '.zip'  # ensure no directory
    send_file Backup.new.backup_path.join(basename)
  end

  # create new one
  def new
    Backup.new.backup
    redirect_to admin_backups_path, notice: 'New backup file created.'
  end
end
