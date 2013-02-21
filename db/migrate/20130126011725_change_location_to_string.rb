class ChangeLocationToString < ActiveRecord::Migration
  def change
    change_column :instructables, :location, :string
  end
end
