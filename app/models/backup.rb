require 'zip/zip'

class Backup
  def zip_filename
    @zip_filename ||= "#{base}.zip"
  end

  def now_filename
    @now_filename ||= Time.now.strftime('thing-%Y%m%d-%H%M%S')
  end

  def backup_path
    @backup_path ||= Rails.root.join('tmp', 'backup')
  end

  def make_dirs
    Dir.mkdir(backup_path) unless Dir.exists?(backup_path)
    Dir.mkdir(base)
  end

  def tables
    [ User, InstructorProfileContact, Instructable, Instance, Changelog ]
  end

  def base
    Rails.root.join(backup_path, now_filename)
  end

  def backup
    make_dirs

    @filenames = []
    ActiveRecord::Base.transaction do
      tables.each do |table|
        filename = "#{table.table_name}.json"
        File.open("#{base}/#{filename}", 'w') do |f|
          f.write table.all.to_json
        end
        @filenames << filename
      end
    end

    Zip::ZipFile.open(zip_filename, Zip::ZipFile::CREATE) do |zip|
      @filenames.each do |filename|
        zip.add("#{now_filename}/#{filename}", "#{base}/#{filename}")
      end
    end

    @filenames.each do |filename|
      File.unlink("#{base}/#{filename}")
    end

    Dir.unlink(base)

    zip_filename
  end

  def list_backup_files
    Dir.entries(backup_path).select { |x| File.file?("#{backup_path}/#{x}") }.sort.reverse
  end
end
