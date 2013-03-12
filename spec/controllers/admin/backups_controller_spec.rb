require 'spec_helper'

describe Admin::BackupsController do
  before :each do
    log_in admin: true
  end

  it '#index with no files' do
    Backup.any_instance.stub(:list_backup_files).and_return([])
    visit admin_backups_path
    page.should have_content 'No backups found.'
    page.should have_content 'Make a new backup'
  end

  it '#index with a file' do
    Backup.any_instance.stub(:list_backup_files).and_return(['flarg.zip', 'blatz.zip'])
    visit admin_backups_path
    page.should have_link 'flarg.zip'
    page.should have_link 'blatz.zip'
  end

  it '#show' do
    Admin::BackupsController.any_instance.should_receive(:send_file)
    Admin::BackupsController.any_instance.stub(:render)
    visit admin_backup_path('flarg.zip')
  end

  it '#new' do
    Backup.any_instance.stub(:backup)
    visit new_admin_backup_path
    page.should have_content 'New backup file created.'
  end
end
