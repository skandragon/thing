class AddLocationTypeToInstructables < ActiveRecord::Migration
  def change
    add_column :instructables, :location_type, :string, default: 'track'
    Instructable.reset_column_information

    Instructable.all.each do |i|
      if i.location_camp?
        i.location_type = 'private-camp'
      else
        i.location_type = 'track'
      end
      i.save!
    end

    remove_column :instructables, :location_camp
  end
end
