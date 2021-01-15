class DropColumnTeachFormatFromInstructables < ActiveRecord::Migration[5.0]
  def up
    remove_column :instructables, :teach_format
  end
  def down
    add_column :instructables, :teach_format, :string, :default => 'I'
  end
end
