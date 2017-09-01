# This migration comes from thinkspace_common (originally 20161024000000)
class AddUnlockAtToThinkspaceCommonTimetables < ActiveRecord::Migration

  def up
    change_table :thinkspace_common_timetables do |t|
      t.datetime :unlock_at
      t.datetime :unlocked_at
    end
  end

  def down
    change_table :thinkspace_common_timetables do |t|
      t.remove :unlock_at
      t.remove :unlocked_at
    end
  end

end
