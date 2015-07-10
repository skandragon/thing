require 'rails_helper'

describe Backup do
  let (:backup) { Backup.new }

  it '#backup_path' do
    backup.backup_path.to_s.should =~ /\/tmp\/backup$/
  end

  it '#base' do
    backup.base.to_s.should =~ /tmp\/backup\/thing-20\d\d\d\d\d\d-\d\d\d\d\d\d$/
  end

  it '#zip_filename' do
    backup.zip_filename.to_s.should =~ /\/thing-20\d\d\d\d\d\d-\d\d\d\d\d\d\.zip$/
  end

  it '#make_dirs' do
    Dir.should_receive(:mkdir).twice
    Dir.should_receive(:exists?).and_return(false)
    backup.make_dirs
  end

  it '#backup' do
    begin
      path = backup.backup
      File.exists?(path).should be_truthy
    ensure
      File.unlink(backup.zip_filename) if File.exist?(backup.zip_filename)
    end
  end

  it '#list_backup_files' do
    targets = [ '.', '..', 'thing-20130101-010101.zip', 'thing-20130101-010102.zip' ]
    Dir.should_receive(:entries).with(backup.backup_path).and_return(targets)
    File.should_receive(:file?).and_return(false, false, true, true)
    backup.list_backup_files.sort.should == targets[2..3].sort
  end

end
