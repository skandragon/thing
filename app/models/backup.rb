require 'zip/zip'

class Backup
  def self.make_backup
    tables = [
      User, InstructorProfile, InstructorProfileContact,
      Instructable, Instance
    ]

    now = Time.now.strftime("thing-%Y%m%d-%H%M%S")
    base = Rails.root.join("tmp", "backup", now)

    backup_path = Rails.root.join("tmp", "backup")
    Dir.mkdir(backup_path) unless Dir.exists?(backup_path)
    Dir.mkdir(base)

    @filenames = []
    ActiveRecord::Base.transaction do
      for table in tables
        filename = "#{table.table_name}.json"
        File.open("#{base}/#{filename}", "w") do |f|
          f.write table.all.to_json
        end
        @filenames << filename
      end
    end

    Zip::ZipFile.open("#{base}.zip", Zip::ZipFile::CREATE) do |zip|
      for filename in @filenames
        zip.add("#{now}/#{filename}", "#{base}/#{filename}")
      end
    end

    for filename in @filenames
      File.unlink("#{base}/#{filename}")
    end

    Dir.unlink(base)

    "#{base}.zip"
  end

  def self.list_backups
    base = Rails.root.join("tmp", "backup")
    Dir.entries(base).select { |x| File.file?("#{base}/#{x}") }.sort.reverse
  end
end
