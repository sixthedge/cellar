# This migration comes from thinkspace_common (originally 20160501000000)
class MigrateAndRemoveDueAt < ActiveRecord::Migration

  ActiveRecord::Base.transaction do
    def change
      say ('-' * 100)
      create_table :thinkspace_common_timetables, force: true do |t|
        t.references  :user
        t.references  :timeable,  polymorphic: true
        t.references  :ownerable, polymorphic: true
        t.datetime    :release_at
        t.datetime    :due_at
        t.timestamps
        t.index  [:timeable_id, :timeable_type],    name: :idx_thinkspace_common_timetables_on_timeable
        t.index  [:ownerable_id, :ownerable_type],  name: :idx_thinkspace_common_timetables_on_ownerable
      end
      if table_exists?(:thinkspace_casespace_assignments) && column_exists?(:thinkspace_casespace_assignments, :due_at)
        klass = Thinkspace::Casespace::Assignment
        count = migrate_datetime_columns_for(klass)
        remove_column :thinkspace_casespace_assignments, :due_at
        remove_column :thinkspace_casespace_assignments, :release_at
        klass.reset_column_information
        say_class_done(klass, count)
      else
        say "====> Did not migrate or remove assignments table release_at/due_at columns.  Table did not exist!"
      end
      say ('-' * 100)
    end
  end # transaction

  private

  def say_class_done(klass, count)
    say "\n"
    say "==> Migrated #{klass.name.inspect} release_at/due_at."
    say "    #{count} timetable records created."
    say "    #{klass.inspect}"
    say "\n"
  end

  def migrate_datetime_columns_for(klass)
    count = 0
    has_release_at = column_exists?(klass.table_name.to_sym, :release_at)
    klass.all.each do |record|
      tt = create_due_at_record(record, has_release_at)
      count += 1  if tt.present?
    end
    count
  end

  def create_due_at_record(record, has_release_at)
    if has_release_at
      return nil if record.read_attribute(:release_at).blank? && record.read_attribute(:due_at).blank?
    else
      return nil if record.read_attribute(:due_at).blank?
    end
    tt               = Thinkspace::Common::Timetable.new
    tt.timeable_id   = record.id
    tt.timeable_type = record.class.name
    tt.release_at    = record.read_attribute(:release_at)  if has_release_at
    tt.due_at        = record.read_attribute(:due_at)
    raise "Create Timeable record failed #{tt.errors.messages.inspect}." unless tt.save
    tt
  end

end
