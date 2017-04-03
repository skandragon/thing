require 'rails_helper'

describe Admin::BackupsController, type: :controller do
  before :each do
    log_in admin: true
  end

  it '#index with no files' do
    Backup.any_instance.stub(:list_backup_files).and_return([])
    visit admin_backups_path
    expect(page).to have_content 'No backups found.'
    expect(page).to have_content 'Make a new backup'
  end

  it '#index with a file' do
    Backup.any_instance.stub(:list_backup_files).and_return(['flarg.zip', 'blatz.zip'])
    visit admin_backups_path
    expect(page).to have_link 'flarg.zip'
    expect(page).to have_link 'blatz.zip'
  end

  it '#show' do
    Admin::BackupsController.any_instance.should_receive(:send_file)
    Admin::BackupsController.any_instance.stub(:render)
    visit admin_backup_path('flarg.zip')
  end

  it '#new' do
    Backup.any_instance.stub(:backup)
    visit new_admin_backup_path
    expect(page).to have_content 'New backup file created.'
  end
end
