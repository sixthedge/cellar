# This migration comes from thinkspace_casespace (originally 20150901000002)
class AddStateThinkspaceCasespacePhases < ActiveRecord::Migration

  change_table :thinkspace_casespace_phases do |t|
    t.string :state
    t.index  :state,  name: :idx_thinkspace_casespace_phases_on_state
  end

  Thinkspace::Casespace::Phase.reset_column_information
  Thinkspace::Casespace::Phase.where(active:  true).update_all(state: 'active')
  Thinkspace::Casespace::Phase.where(active: false).update_all(state: 'inactive')

  change_table :thinkspace_casespace_phases do |t|
    t.remove :active
  end


end
