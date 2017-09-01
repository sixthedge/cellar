# This migration comes from thinkspace_casespace (originally 20161210000001)
class AddAssignmentTypeId < ActiveRecord::Migration

  change_table :thinkspace_casespace_assignments do |t|
    t.references :assignment_type
  end

end