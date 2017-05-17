# This migration comes from thinkspace_casespace (originally 20160208000000)
class AddValueToThinkspaceCasespacePhaseTemplates < ActiveRecord::Migration

  change_table :thinkspace_casespace_phase_templates do |t|
    t.json :value
  end

end
