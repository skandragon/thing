class AddTeachFormatToInstructables < ActiveRecord::Migration[5.0]
  def change
    add_column :instructables, :teach_format, :string, :default => 'I'
  end

  def down
    remove_column :instructables, :teach_format
  end
end
