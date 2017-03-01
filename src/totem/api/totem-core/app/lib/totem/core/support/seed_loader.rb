module Totem
  module Core
    module Support
      class SeedLoader

        attr_accessor :load_errors, :quiet, :namespace_lookup, :new_model_class_names

        def initialize(options={})
          @load_errors           = []
          @namespace_lookup      = {}
          @new_model_class_names = []
          @print_tables          = options.has_key?(:print_tables) ? options[:print_tables] : false
        end

        def print_tables; print_models;  end

        def set_namespaces(namespaces)
          namespaces.each do |key, path|
            namespace_lookup[key] = nil
            set_namespace(key, path)
          end
        end

        def set_namespace(key, path)
          raise_error "Namespace with key [#{key}] already exists"  if namespace_lookup[key].present?
          namespace_name = path.to_s.camelize
          namespace      = namespace_name.safe_constantize
          if namespace.present?
            namespace_lookup[key] = namespace
          else
            message "Key [#{key.inspect}] to namespace [#{namespace_name.inspect}] cannot be constantized.  Any references to this key will result in an error."
          end
        end

        def message(msg, level=:info)
          return if quiet && level != :error
          return puts '' if msg.blank?
          msg.each_line do |m|
            m.blank? ? puts('') : puts("[seed #{level}] " + m)
          end
        end

        def load(*args)
          options    = args.extract_options!
          seed_files = options[:seeds]      || nil
          test_files = options[:test_data]  || nil
          @quiet     = options[:quiet]      || false

          ActiveRecord::Base.transaction do
            [seed_files].flatten.compact.each do |seed_file|
              message "Processing seed file [#{seed_file}]"
              require seed_file
              raise_error if has_errors?   # rollback all changes if there are seed errors
              seed_results
            end
            if load_test_data?
              [test_files].flatten.compact.each do |test_file|
                message "Processing test data seed file [#{test_file}]"
                require test_file
                raise_error if has_errors?  # rollback all changes if there are seed errors
                seed_results
              end
            end
          end
          print_models  if @print_tables.present?
        end

        def load_test_data?
          Rails.env.development? or Rails.env.test? or Rails.env.production? # Heroku
        end

        # ######################################################################################
        # @!group Dynamic Seed Model Namespaces

        def user_class
          klass = resolve_namespace(:user)  # user is a special key as it is a fully qualified model class already
          raise_error "User class [#{class_name}] could not be constantized" if klass.blank?
          klass
        end

        def model_class(*args)
          options    = args.extract_options!
          ns_key     = args.shift
          model      = args.shift || raise_error("Model class cannot be blank [#{args.inspect}]")
          namespace  = resolve_namespace(ns_key)
          model_name = model.to_s.classify
          class_name = "#{namespace}::#{model_name}"
          klass      = class_name.safe_constantize
          raise_error "Class [#{class_name}] could not be constantized" if klass.blank?   # rollback all changes if there are seed errors
          klass
        end

        def new_model(*args)
          options = args.extract_options!
          ns_key  = args.shift
          model   = args.shift
          klass   = model_class(ns_key, model, options)
          new_model_class_names.push(klass.name)  unless new_model_class_names.include?(klass.name)
          model = klass.new
          options.blank? ? model : populate_model(model, options)
        end

        def populate_model(model, options)
          attrs = model.attribute_names
          model.class.stored_attributes.each {|k,v| attrs += v}
          attrs.each do |a|
            a_sym = a.to_sym
            next if a_sym == :id

            case
            when a.to_s.end_with?('_id')
              if (id = options[a_sym]).present?
                model.send "#{a_sym}=", id
              else
                assoc_sym = a.sub(/_id$/,'').to_sym
                if (assoc = options[assoc_sym]).present?
                  model.send "#{a_sym}=", assoc.id
                end
              end
            when a.to_s.end_with?('_type')  # assume polymorphic type
              assoc_sym = a.sub(/_type$/,'').to_sym
              if (assoc = options[assoc_sym]).present?
                model.send "#{a_sym}=", assoc.class.name
              else
                model.send "#{a_sym}=", options[a_sym]  if options.has_key?(a_sym)
              end
            else
              model.send "#{a_sym}=", options[a_sym]  if options.has_key?(a_sym)
            end

          end
          model
        end

        def get_association(*args)
          options          = args.extract_options!
          model            = args.shift
          ns_key           = args.shift
          association      = args.shift
          options[:assign] = false
          assoc_name       = resolve_association_name(model, ns_key, association, options)
          model.send(assoc_name)
        end

        def add_association(*args)
          options          = args.extract_options!
          model            = args.shift
          ns_key           = args.shift
          association      = args.shift
          value            = args.shift
          options[:assign] = true
          name             = resolve_association_name(model, ns_key, association, options)
          model.send(name, value)
        end

        def resolve_namespace(ns_key)
          namespace_lookup[ns_key] || raise_error("Namespace key [#{ns_key}] is not set")
        end

        def resolve_association_name(*args)
          options     = args.extract_options!
          model       = args.shift
          ns_key      = args.shift
          association = args.shift
          namespace   = resolve_namespace(ns_key)
          namespace   = namespace.to_s.underscore.gsub('/','_')
          namespace  += '_' + association.to_s.underscore
          association_name = options[:assign] ? "#{namespace}=".to_sym : namespace.to_sym
          raise_error "Model [#{model} does not have association method [#{association_name}]"  unless model.respond_to?(association_name)
          association_name
        end

        # ######################################################################################
        # @!group Test Seed Data

        def test_data_seed_name
          name = ENV['TOTEM_TEST_DATA_SEED_NAME']
          name.present? ? name : Rails.env.test? ? 'test' : 'default'
        end

        # ######################################################################################
        # @!group Test Config File

        def test_config_names
          configs = ENV['CONFIG'] || 'default'
          configs.split(',').map {|c| c.to_s.strip}
        end

        def test_config_auto_input?
          auto_input = ENV['AUTO_INPUT'] || ENV['AI'] || false
          (auto_input.present? && auto_input == 'true') || false
        end

        def test_config_file(options={})
          file = test_config_file_path(options)
          message ">>Loading config file #{file.inspect}."
          # YAML.load(ERB.new(File.read(file)).result).deep_symbolize_keys  # if want to ERB the config files
          YAML.load(File.read(file)).deep_symbolize_keys
        end

        def test_config_content(options={}); File.read(test_config_file_path(options)); end

        def test_config_file_path(options={})
          options.symbolize_keys!
          ns_key   = options[:namespace]
          data_dir = options[:test_data_dir] || test_data_seed_name
          filename = options[:config]
          raise_error "Namespace is blank in options #{options.inspect}"  if ns_key.blank?
          raise_error "Test data directory is blank in options #{options.inspect}"  if data_dir.blank?
          raise_error "Config name is blank in options #{options.inspect}"  if filename.blank?
          file = File.join(db_data_dir(ns_key.to_sym), data_dir, "_config_#{filename}.yml")
          file = File.join(db_data_dir(ns_key.to_sym), data_dir, "#{filename}.yml")  unless File.exists?(file) # _config_filename (legacy version) doesn't exsit try without _config_
          raise_error "Missing config file: #{file}"  unless File.exists?(file)
          file
        end

        def test_import_file(options={})
          file = test_import_file_path(options)
          message ">>Loading import file #{file.inspect}."
          # YAML.load(ERB.new(File.read(file)).result).deep_symbolize_keys  # if want to ERB the config files
          YAML.load(File.read(file)).deep_symbolize_keys
        end

        def test_import_content(options={}); File.read(test_import_file_path(options)); end

        def test_import_file_path(options={})
          options.symbolize_keys!
          ns_key   = options[:namespace]
          data_dir = options[:test_data_dir] || test_data_seed_name
          filename = options[:import]
          raise_error "Namespace is blank in options #{options.inspect}"  if ns_key.blank?
          raise_error "Test data directory is blank in options #{options.inspect}"  if data_dir.blank?
          raise_error "Import name is blank in options #{options.inspect}"  if filename.blank?
          file = File.join(db_data_dir(ns_key.to_sym), data_dir, "#{filename}.yml")
          raise_error "Missing import file: #{file}"  unless File.exists?(file)
          file
        end

        # ######################################################################################
        # @!group Engine db Directory

        def db_dir(ns_key)
          namespace = resolve_namespace(ns_key)
          namespace = namespace.to_s.underscore.gsub('/','_')
          engine    = ::Totem::Settings.engine.get_by_name(namespace)
          return nil if engine.blank?
          engine = engine.first
          db_dir = engine.config.paths['db']
          return nil if db_dir.blank?
          db_dir.first
        end

        def db_data_dir(ns_key)
          dir = db_dir(ns_key)
          return nil if dir.blank?
          File.join(dir, 'test_data')
        end

        def db_helpers_dir(ns_key)
          dir = db_dir(ns_key)
          return nil if dir.blank?
          File.join(dir, 'helpers')
        end

        def require_platform_helpers(platform_name)
          @_required_platform_helpers ||= Array.new
          return if @_required_platform_helpers.include?(platform_name.to_sym)  # already required
          message "++Requiring platform #{platform_name.to_s.inspect} seed helpers."
          @_required_platform_helpers.push platform_name.to_sym
          get_platform_helper_files(platform_name).each do |helper|
            require helper
          end
        end

        def require_helper(ns_key, filename)
          helpers_dir = db_helpers_dir(ns_key)
          return nil if helpers_dir.blank?
          filename = filename.to_s
          filename += '_helper'  unless filename.end_with?('_helper')
          require File.join(helpers_dir, filename)
        end

        def require_data_files(ns_key, dir)
          root_data_dir = db_data_dir(ns_key)
          data_dir      = File.join(root_data_dir, dir.to_s)
          files         = Array.new
          if Dir.exist?(data_dir)
            dir_files = Dir.glob(File.join(data_dir, '*.rb'))
            files += dir_files if dir_files.present?
          end
          dir_files.each do |file|
            next if File.basename(file).start_with?('_')
            require file
          end
        end

        def require_data_file(ns_key, filename)
          root_data_dir = db_data_dir(ns_key)
          file          = File.join(root_data_dir, filename.to_s)
          raise_error "File #{file.inspect} is not a file and cannot be required." unless File.file?(file)
          require file
        end

        def get_platform_helper_files(platform_name)
          raise_error "Platform name is blank in require platform helpers."  if platform_name.blank?
          engine_names = ::Totem::Settings.engine.name_and_engine
          helpers      = Array.new
          engine_names.each do |engine_name, engine|
            engine_platform = ::Totem::Settings.registered.engine_platform_name(engine_name)
            next unless platform_name.to_s == engine_platform
            db = engine.config.paths['db'].first
            next unless db.present?
            helpers_dir = File.join(db, 'helpers')
            if Dir.exist?(helpers_dir)
              engine_helpers = Dir.glob(File.join(helpers_dir, '*_helper.rb'))
              helpers += engine_helpers if engine_helpers.present?
            end
          end
          helpers
        end

        # Include instead of 'require'.  Includes methods in @seed.helper.method-name.

        def include_platform_helpers(platform_name)
          set_helper_instance
          get_platform_helper_files(platform_name).each do |filename|
            helper.instance_eval(get_helper_content(filename))
          end
        end

        def include_helper(ns_key, filename)
          helpers_dir = db_helpers_dir(ns_key)
          return nil if helpers_dir.blank?
          set_helper_instance
          filename  = filename.to_s
          filename += '_helper'  unless filename.end_with?('_helper')
          filename += '.rb'      unless filename.end_with?('.rb')
          filename  = File.join(helpers_dir, filename)
          content   = get_helper_content(filename)
          helper.instance_eval(get_helper_content(filename))
        end

        def get_helper_content(filename)
          raise_error "Helper file #{filename.inspect} is not a file and cannot be included." unless File.file?(filename)
          content = File.read(filename)
          content.sub!(/^\s*public.*?\n/, '') if content.match('public') # remove 'public' class statement (methods will be public)
          content
        end

        attr_reader :helper  # used to reference the included helper methods e.g. @seed.helper.method-name

        # Create a new class to include the seed helper methods so will not collide with any existing
        # instance method names (e.g. a minitest instance).
        def set_helper_instance
          @helper ||= Helper.new(self)
        end

        class Helper
          def initialize(seed_loader)
            @seed = seed_loader  # set @seed to this seed_loader so any included methods can reference @seed.method-name
          end
        end

        # ######################################################################################
        # @!group Reset Tables

        def reset_tables?; (ENV['RESET'] || ENV['R'] || nil) == 'true'; end

        # Reset tables that start with value(s) in 'args' (default is registered engine names).
        # e.g. @seed.reset_tables; @seed.reset_tables(:thinkspace); @seed.reset_tables(:thinkspace, :totem)
        def reset_tables(*args)
          return unless reset_tables?
          table_names = select_reset_tables(args)
          message "==Resetting #{table_names.length} tables.", :warn
          [table_names].flatten.compact.sort.each do |table_name|
            delete_all_table_records(table_name)
          end
          reset_common_tables
          run_domain_loader
        end

        def reset_common_tables
          if 'PaperTrail::Version'.safe_constantize.present?
            message "==Resetting 'versions' table.", :warn
            delete_all_table_records(:versions)
          end
          if 'ActsAsTaggableOn::Tag'.safe_constantize.present?
            message "==Resetting 'tags' and 'taggings' table.", :warn
            delete_all_table_records(:tags)
            delete_all_table_records(:taggings)
          end
        end

        def run_domain_loader
          message "==Loading domain data."
          Totem::Core::Database::Domain::Loader.new.load_files
        end

        def select_reset_tables(args)
          engine_names = args.blank? ? ::Totem::Settings.registered.engines : args
          active_record_base_connection.tables.select {|tn| select_reset_table?(tn, engine_names)}
        end

        def select_reset_table?(table_name, engine_names)
          engine_names.each do |en|
            return true if table_name.to_s.start_with?(en.to_s)
          end
          false
        end

        def delete_all_table_records(table_name)
          return if table_name.blank?
          active_record_base_connection.execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY") # restart ids at 1
        end

        def active_record_base_connection; ::ActiveRecord::Base.connection; end

        # ######################################################################################
        # @!group Print table rows

        def print_models
          return puts("[stats] No new table rows added")  if new_model_class_names.blank?
          require 'pp'
          new_model_class_names.sort.each do |name|
            klass = name.safe_constantize
            raise_error "Could not constantize class name [#{name}] to print rows"  if klass.blank?
            print_table(klass)
          end
        end

        def print_table(klass)
          puts "\n===== Table: #{klass.name} ===== #{klass.name.demodulize}\n"
          pp klass.all
          puts "\n"
        end

        # ######################################################################################
        # @!group Seed Errors

        def create_error(object)
          msg = "\n"
          msg += "Model:        [#{object.class.name}]\n"
          msg += "Instance:     [#{object.inspect}]\n"
          msg += "Model Errors: [#{object.errors.full_messages.join(', ')}]\n"
          message msg, :error
          raise_error
        end

        def add_error(msg)
          message msg, :error
          load_errors.push(msg)
        end

        def has_errors?
          load_errors.present?
        end

        def raise_error(message='')
          raise "Seed exception.  #{message}"
        end

        def seed_results
          if has_errors?
            message "*Errors*. Seed completed with #{load_errors.length} errors.", :error
          else
            message "--Successful. Seed completed with no known errors."
            message "--Check the log or console to make sure there are no mass-assignment warnings."
          end
          message "\n"
        end

        include Shared

      end
    end
  end
end
