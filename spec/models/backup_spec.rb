require 'rails_helper'

describe Backup do
  let (:backup) { Backup.new }

  it '#backup_path' do
    expect(backup.backup_path.to_s).to match /\/tmp\/backup$/
  end

  it '#base' do
    expect(backup.base.to_s).to match /tmp\/backup\/thing-20\d\d\d\d\d\d-\d\d\d\d\d\d$/
  end

  it '#zip_filename' do
    expect(backup.zip_filename.to_s).to match /\/thing-20\d\d\d\d\d\d-\d\d\d\d\d\d\.zip$/
  end

  it '#make_dirs' do
    expect(Dir).to receive(:mkdir).twice
    expect(Dir).to receive(:exists?).and_return(false)
    backup.make_dirs
  end

  it '#backup' do
    begin
      path = backup.backup
      expect(File.exists?(path)).to be_truthy
    ensure
      File.unlink(backup.zip_filename) if File.exist?(backup.zip_filename)
    end
  end

  it '#list_backup_files' do
    targets = [ '.', '..', 'thing-20130101-010101.zip', 'thing-20130101-010102.zip' ]
    expect(Dir).to receive(:entries).with(backup.backup_path).and_return(targets)
    expect(File).to receive(:file?).and_return(false, false, true, true)
    expect(backup.list_backup_files.sort).to eql targets[2..3].sort
  end

end
