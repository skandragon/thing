class AddInPersonVirtualArray < ActiveRecord::Migration[5.0]
  def up
    add_column :instructables, :inp_virt, :string, :limit => 255, array: true
    end
def down
    remove_column :instructables, :inp_virt
  end
end
