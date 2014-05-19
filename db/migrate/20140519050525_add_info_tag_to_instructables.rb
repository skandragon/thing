class AddInfoTagToInstructables < ActiveRecord::Migration
  def change
    add_column :instructables, :info_tag, :string
  end
end
