# This migration comes from thinkspace_casespace (originally 20150901000001)
class AddStateThinkspaceCasespaceAssignments < ActiveRecord::Migration

  change_table :thinkspace_casespace_assignments do |t|
    t.string :state
    t.index  :state,  name: :idx_thinkspace_casespace_assignments_on_state
  end

  Thinkspace::Casespace::Assignment.reset_column_information
  Thinkspace::Casespace::Assignment.where(active:  true).update_all(state: 'active')
  Thinkspace::Casespace::Assignment.where(active: false).update_all(state: 'inactive')

  change_table :thinkspace_casespace_assignments do |t|
    t.remove :active
  end


end
