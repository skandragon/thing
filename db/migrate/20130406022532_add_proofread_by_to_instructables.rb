class AddProofreadByToInstructables < ActiveRecord::Migration
  def change
    add_column :instructables, :proofread_by, :integer, array: true, default: '{}'
  end
end
