class AddAssignmentTypeId < ActiveRecord::Migration

  change_table :thinkspace_casespace_assignments do |t|
    t.references :assignment_type
  end

end