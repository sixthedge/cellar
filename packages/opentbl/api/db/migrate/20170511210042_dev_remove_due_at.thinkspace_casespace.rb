# This migration comes from thinkspace_casespace (originally 20160501000001)
class DevRemoveDueAt < ActiveRecord::Migration
  # If drop the database (e.g. in development) the thinkspace_common migration will not remove the columns
  # since the assignments table does not exist yet. 
  def change
    say ('-' * 100)
    unless Rails.env.production?
      if table_exists?(:thinkspace_common_timetables)
        klass = Thinkspace::Casespace::Assignment
        klass.reset_column_information
        if column_exists?(:thinkspace_casespace_assignments, :due_at)
          remove_column :thinkspace_casespace_assignments, :due_at
          remove_column :thinkspace_casespace_assignments, :release_at
          klass.reset_column_information
          say "==>   Removed assignment release_at and due_at"
          say "      #{klass.inspect}"
        else
          say "====> Did not remove assignments table release_at/due_at columns.  Already removed!"
        end
      end
    end
    say ('-' * 100)
  end
end
