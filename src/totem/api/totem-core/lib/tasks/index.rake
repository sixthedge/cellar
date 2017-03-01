namespace :totem do

  namespace :index do

    desc "List table indexes - rake totem:index:list or rake totem:index:list[all]"
    task :list, [:all] => [:environment] do |t, args|
      include TotemHelperModule
      db_connection = totem_database_connection
      totem_output_header("Table columns with an index (id columns not included):")
      totem_database_tables(db_connection).collect do |table|
        indexed_columns = totem_table_columns_with_index(table, db_connection)
        totem_output_index_columns(table, indexed_columns, args.all == 'all')
      end
    end

    desc "Missing table foreign key indexes - rake totem:index:missing or rake totem:index:missing[all]"
    task :missing, [:all] => [:environment] do |t, args|
      include TotemHelperModule
      totem_output_header("Table foreign key columns without an index:")
      puts "Polymorphic indexes typically would be: add_index :tablename, [polymorphic_id, polymorphic_type]\n"
      puts "Use SQL Explain to test the usefulness of indexes.\n\n"
      db_connection = totem_database_connection
      totem_database_tables(db_connection).collect do |table|
        columns         = totem_table_id_columns(table, db_connection)
        indexed_columns = totem_table_columns_with_index(table, db_connection)
        unindexed       = columns - indexed_columns
        totem_output_index_columns(table, unindexed, args.all == 'all')
      end
    end

  end

end
