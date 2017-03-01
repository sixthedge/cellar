class CreateThinkspaceCasespaceAssignmentTypes < ActiveRecord::Migration
  def change

    create_table :thinkspace_casespace_assignment_types, force: true do |t|
      t.string :title
      t.string :path # What the route is mounted as in the client (e.g. 'cases' for thinkspace-case).
      t.string :description
      t.string :img_src
      t.timestamps
    end
    
  end
end
