class AddSettingsToThinkspaceCasespaceAssignmentsAndPhases < ActiveRecord::Migration

  change_table :thinkspace_casespace_assignments do |t|
    t.json :settings
  end

  change_table :thinkspace_casespace_phases do |t|
    t.json :settings
  end

  Thinkspace::Casespace::Assignment.reset_column_information
  Thinkspace::Casespace::Phase.reset_column_information

end
