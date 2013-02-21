class AddToInstructables < ActiveRecord::Migration
  def change
    remove_column :instructables, :parent
    add_column :instructables, :duration, :float
    remove_column :instructables, :subject
    add_column :instructables, :culture, :string
    add_column :instructables, :topic, :string
    add_column :instructables, :subtopic, :string
    rename_column :instructables, :description, :description_web
    add_column :instructables, :description_book, :text
    add_column :instructables, :additional_instructors, :string, :array => true
    add_column :instructables, :location_camp, :boolean
    add_column :instructables, :camp_name, :string
    add_column :instructables, :camp_address, :string
    add_column :instructables, :camp_reason, :string
    add_column :instructables, :adult_only, :boolean
    add_column :instructables, :adult_reason, :string
    add_column :instructables, :fee_itemization, :text
    add_column :instructables, :requested_days, :date, :array => true
    add_column :instructables, :requested_time, :string
    add_column :instructables, :repeat_count, :integer, :default => 0
    add_column :instructables, :scheduling_additional, :text
    add_column :instructables, :special_needs, :string, :array => true
    add_column :instructables, :special_needs_description, :text
    add_column :instructables, :heat_source, :boolean
    add_column :instructables, :head_source_description, :text
  end
end
