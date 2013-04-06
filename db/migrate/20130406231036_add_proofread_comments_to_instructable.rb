class AddProofreadCommentsToInstructable < ActiveRecord::Migration
  def up
    add_column :instructables, :proofreader_comments, :text
    
    Instructable.where(proofread: true).each do |instructable|
      instructable.proofread_by = [ 118, 130 ]
      instructable.save!
    end
  end
  
  def down
    remove_column :instructables, :proofreader_comments
  end
end
