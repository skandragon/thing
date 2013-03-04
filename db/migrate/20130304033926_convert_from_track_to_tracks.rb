class ConvertFromTrackToTracks < ActiveRecord::Migration
  def change
    add_column :users, :tracks, :string, array: true, default: '{}'
    User.reset_column_information
    User.all.each do |u|
      u.tracks = [u.coordinator_track]
      u.save!
    end
    remove_column :users, :coordinator_track
  end
end
