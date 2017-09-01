# This migration comes from thinkspace_common (originally 20160824000000)
class AddSandboxSpaceIdToThinkspaceCommonSpaces < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_spaces do |t|
      t.references  :sandbox_space
    end
    Thinkspace::Common::Space.reset_column_information # reset columns if seeding as well
  end

  def down
    change_table :thinkspace_common_spaces do |t|
      t.remove :sandbox_space_id
    end
  end

end
