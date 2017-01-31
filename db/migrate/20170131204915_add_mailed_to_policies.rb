class AddMailedToPolicies < ActiveRecord::Migration[5.0]
  def change
    add_column :policies, :mailed_on, :datetime
  end
end
