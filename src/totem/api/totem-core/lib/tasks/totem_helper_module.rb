module TotemHelperModule

  # NOTE: methods defined in rake tasks are NOT namepsaced to the rake namespace (rake namespaces only used for task organization).
  # Putting methods in this module so will not collide with any other rake tasks.
  # This module needs to be include in any rake task requireing these helper methods.

  puts "[env] Running in [#{Rails.env}] environment.\n"

  def totem_message(msg, level=:info)
    return puts '' if msg.blank?
    msg.each_line do |m|
      m.blank? ? puts('') : puts("[#{level}] " + m)
    end
  end

  def totem_eager_load
    totem_eager_load_application
    totem_eager_load_engines
  end

  def totem_eager_load_application
    ::Rails.application.eager_load!
  end

  def totem_eager_load_engines
    ::Totem::Settings.engines.each do |engine|
       engine.eager_load!
    end
  end

  def totem_framework_name
    ::Totem::Settings.registered.framework_name
  end

  # Database
  def totem_seed_order_all
    ::Totem::Settings.seed.order_all
  end

  def totem_seed_order(name)
    order = ::Totem::Settings.seed.order(name) || []
    order.select { |e| e.starts_with?(name)}
  end

  def totem_engine
    ::Totem::Settings.engine
  end

  def totem_registered_engines
    @totem_registered_engines ||= ::Totem::Settings.registered.engines
  end

  def totem_engines
    @totem_engines ||= ::Totem::Settings.engines
  end

  def totem_engine_name(engine)
    totem_engine.engine_name(engine)
  end

  def totem_engine_by_name(name)
    engine = totem_engine.get_by_name(name)
    raise "*ERROR* Engine [#{name}] not found."              if engine.blank?
    raise "*ERROR* More than one engine matched [#{name}]."  if engine.length > 1
    engine.first
  end

  def totem_engines_by_starts_with(name)
    engines = totem_engine.get_by_starts_with(name)
    raise "*ERROR* No engines start with [#{name}]."   if engines.blank?
    engines
  end

  def totem_has_migration_folder?(engine)
    found_folder = false
    root  = engine.root
    paths = engine.config.paths['db/migrate']
    paths.each do |path|
      dir = File.join(root, path)
      found_folder = File.directory?(dir)
      break if found_folder
    end
    found_folder
  end

  def totem_print_seed_order_all
    totem_print_seed_order(totem_seed_order_all)
  end

  def totem_print_seed_order(order=seed_order)
    order.each_with_index do |name, index|
      count = "#{index+1}.".ljust(3)
      totem_message "#{count} #{name}"
    end
    totem_message ''
  end

  # Associations
  def totem_output_association_warnings
    warnings = ::Totem::Settings.associations.warnings
    if warnings.blank?
      puts "\n*** No Warnings ***\n\n"
    else
      puts "\n*** #{warnings.length} WARNING(S) ***\n"
      warnings.each_with_index do |warning, index|
        count = "#{index+1}."
        puts "#{count.ljust(5)} #{warning}"
      end
      puts "\n"
    end
  end

  # Index
  def totem_database_connection; ActiveRecord::Base.connection; end

  def totem_database_tables(db_connection=database_connection); db_connection.tables; end

  def totem_table_id_columns(table, db_connection=database_connection)
    id_columns   = db_connection.columns(table).collect(&:name).select {|c| c.end_with?('_id')}
    type_columns = db_connection.columns(table).collect(&:name).select {|c| c.end_with?('_type') && id_columns.include?(c.sub(/_type$/, '_id'))}
    id_columns + type_columns
  end

  def totem_table_columns_with_index(table, db_connection=database_connection)
    db_connection.indexes(table).collect(&:columns).flatten.uniq
  end

  def totem_output_header(text='')
    puts "\n-- #{text} --\n\n"
  end

  def totem_output_index_columns(table, columns, all=false)
    return if columns.blank? && !all
    puts "  #{table}:"
    columns.push('None') if columns.blank?
    columns.each do |column|
      type_column = column.end_with?('able_id','able_type') ? '*' : ''
      puts "    #{type_column}#{column}"
    end
  end

  # ERD
  def totem_erd_options
    {
      title:        'Default ERD Title',
      filename:     'default_erd',
      filetype:     :pdf,
      orientation:  :vertical,
      disconnected: true,
      indirect:     true,
      notation:     :simple,
      polymorphism: true,
      warn:         true,
      attributes:   [:content, :primary_keys, :foreign_keys, :timestamps]
    }
  end

  def totem_erb_filename_location(filename)
    path = File.join(::Rails.root, 'db', filename)
  end

  def totem_erb_select_models(name)
    return nil if name.blank?
    name_class       = name.classify
    model_classes    = ActiveRecord::Base.descendants
    model_classes.select {|m| m.name.starts_with?(name_class)}.collect {|m| m.name}
  end

end
