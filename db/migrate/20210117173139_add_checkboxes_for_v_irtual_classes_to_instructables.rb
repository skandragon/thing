class AddCheckboxesForVIrtualClassesToInstructables < ActiveRecord::Migration[5.0]
  def up
    add_column :instructables, :in_person_class, :boolean, :default => false
    add_column :instructables, :virtual_class, :boolean, :default => false
    add_column :instructables, :contingent_class, :boolean, :default => false
    add_column :instructables, :waiver_signed, :boolean, :default => false

  end

  def down
    remove_column :instructables, :in_person_class
    remove_column :instructables, :virtual_class
    remove_column :instructables, :contingent_class
    remove_column :instructables, :waiver_signed
  end
end
