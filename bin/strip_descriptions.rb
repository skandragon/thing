Instructable.all.each do |i|
  i.description_web = i.description_web.strip unless i.description_web == i.description_web.strip
  i.description_book = i.description_book.strip unless i.description_book == i.description_book.strip
  if i.changed?
    puts "Saving #{i.id}: #{i.name}"
    i.save!
  end
end
