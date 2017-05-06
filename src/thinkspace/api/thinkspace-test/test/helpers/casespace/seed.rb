# IMPORTANT: Must run this rake task if the schema has changed:
# rake totem:db:reset[none] RAILS_ENV='test'

# Examples:
# Test::Casespace::Seed.load(config: :ability)                                #=> load db/test_data/test/ability.yml
# Test::Casespace::Seed.load(config: [:ability, :clone])                      #=> load db/test_data/test/ability.yml & clone.yml
# Test::Casespace::Seed.load(config: :html, dir: :default)                    #=> load db/test_data/default/html.yml
# Test::Casespace::Seed.load(config: :html, dir: :default, auto_input: true)  #=> load db/test_data/default/html.yml and auto input

require File.expand_path('../models', __FILE__)

module Test; module Casespace; class Seed

  @seed                 = nil
  @seed_configs_loaded  = Array.new
  @delete_all_performed = false

  def self.load(options={})
    return unless load_seeds?
    configs      = get_seed_configs_from_options(options)
    dir          = options[:dir] = (options[:dir] || 'test').to_s
    load_configs = Array.new
    configs.each do |config|
      name = File.join(dir, config).to_s
      next if seed_config_loaded?(name)
      add_seed_config_loaded(name)
      load_configs.push(config)
    end
    return if load_configs.blank?
    ENV['CONFIG']                    = load_configs.join(',')
    ENV['AI']                        = options[:auto_input] == true ? 'true' : ''
    ENV['TOTEM_TEST_DATA_SEED_NAME'] = dir
    ENV['SKIP_SEED_CONFIG_REQUIRE']  = 'true'
    delete_database_records(load_configs, options)
    seed.helper.seed_configs_process
  end

  def self.seed
    @seed ||= begin
      seed = new_seed_loader
      set_seed_namespaces(seed)
      include_seed_helpers(seed)
      seed
    end
  end

  private

  def self.load_seeds?; ENV['SEED'] == 'true'; end
  def self.add_seed_config_loaded(config); @seed_configs_loaded.push(config); end
  def self.seed_config_loaded?(config);    @seed_configs_loaded.include?(config); end

  def self.get_seed_configs_from_options(options)
    config = options[:config]
    raise "Seed load config is blank."  if config.blank?
    case
    when config.is_a?(String)  then config.split(',').map {|c| c.strip}
    when config.is_a?(Symbol)  then [config.to_s]
    when config.is_a?(Array)   then config.map {|c| c.to_s.strip}
    else
      raise "Seed load config must be a string, symbol or array."
    end
  end

  def self.delete_database_records(configs, options={})
    delete_records_in_all_database_tables(configs)  if delete_all_records?(options)
  end

  def self.delete_all_records?(options); options[:delete_all] != false; end

  def self.delete_records_in_all_database_tables(configs)
    return if @delete_all_performed
    @delete_all_performed = true
    seed.message "++Delete ALL database records in all tables (#{configs.join(',')})"
    table_names = ActiveRecord::Base.connection.tables.select {|t| t.start_with?('thinkspace')}
    table_names.each {|table_name| delete_all_table_records(table_name)}
    delete_all_table_records(:versions)
    domain_loader.new.load_files('thinkspace*')
  end

  def self.include_seed_helpers(seed)
    seed.include_platform_helpers(:thinkspace)
    dir       = File.join(seed.db_dir(:seed), 'helpers', 'seed_config')
    dir_files = Dir.glob(File.join(dir, '*_helper.rb'))
    helpers   = dir_files.collect {|file| File.join('seed_config', File.basename(file).sub(/_helper\.rb$/,''))}
    helpers.each do |helper|
      seed.include_helper(:seed, helper)
    end
  end

  def self.set_seed_namespaces(seed)
    seed.set_namespace(:common, 'thinkspace/common')
    seed.include_helper(:common, :common)
    seed.helper.set_common_seed_loader_namespaces
  end

  def self.domain_loader; Totem::Core::Database::Domain::Loader; end

  def self.new_seed_loader; ::Totem::Settings.seed.loader; end

  # ###
  # ### Delete Records.
  # ###

  def self.delete_model_class_records_by_ids(klass, ids)
    return if ids.blank?
    klass.where(id: ids).delete_all
  end

  def self.delete_all_model_class_records(klass)
    delete_all_table_records(klass.table_name)
  end

  def self.delete_all_table_records(table_name)
    return if table_name.blank?
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY") # restart ids at 1
  end

end; end; end
