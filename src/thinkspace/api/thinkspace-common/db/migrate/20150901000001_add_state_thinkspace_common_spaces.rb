class AddStateThinkspaceCommonSpaces < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_spaces, force: true do |t|
      t.string :state
      t.index  :state,  name: :idx_thinkspace_common_spaces_on_state
    end

    Thinkspace::Common::Space.reset_column_information
    Thinkspace::Common::Space.update_all(state: 'active')
  end
end
