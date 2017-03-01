module Totem
  module Core
    module Support
      class Configuration

        attr_reader :totem_settings

        # Should always use the public methods to access these instance variables.
        # Listing the instance variables used to provide easily access if needed.
        attr_reader :all_platform_configurations

        def initialize(env)
          @totem_settings = env
        end

        def startup_quiet?; @_startup_quiet ||= (Rails.env.production? || ENV['TOTEM_STARTUP_QUIET'] == 'true'); end
        def startup_no_associations?; @_startup_no_assocations ||= ENV['TOTEM_STARTUP_NO_ASSOCIATIONS'] == 'true'; end
        def startup_no_serializers?;  @_startup_no_serializers ||= ENV['TOTEM_STARTUP_NO_SERIALIZERS'] == 'true'; end

        # ######################################################################################
        # @!group Public

        # define config.
        def config; self; end

        # platform values as defined in config files for all platforms
        def platform_configurations
          # Sets the @all_platform_configurations variable and is referenced in a number of methods
          # via the 'platforms' method during the configuration load process (e.g. why it is not ||=).
          @all_platform_configurations || set_platform_configurations
        end

        def platforms; platform_configurations; end

        def platform(platform_name)
          platform_configurations[platform_name.downcase.to_sym] || ActiveSupport::OrderedOptions.new
        end

        # Array of path settings for the platform name (after resolution)
        def paths(platform_name)
          platform(platform_name).paths
        end

        def model_access(platform_name)
          platform(platform_name).model_access
        end

        def classes(platform_name)
          platform(platform_name).classes
        end

        def modules(platform_name)
          platform(platform_name).modules
        end

        def seed_order(platform_name)
          platform(platform_name).seed_order
        end

        def authentication(platform_name)
          platform(platform_name).authentication
        end

        def authorization(platform_name)
          platform(platform_name).authorization
        end

        def routes(platform_name)
          platform(platform_name).routes
        end

        private

        # ######################################################################################
        # @!group Set Platform Configuration Files

        # Merge all configuration files -> files ending in '.config.yml' from any directory in the rails application.
        # Configuration files must start with the platform name followed by a dot such as 'platform.config.yml'.
        # Filename structure (with example full file name: platform.01.config.yml):
        #   plaform-name:      (required) e.g. totem
        #   merge-order:       (optional) e.g. 01
        #   config-identifier: (required) e.g. config.yml  (note: MUST match totem_settings.option.configuration_file_extension)
        # The files are merged based on merge order or will be merged in the Ruby Dir class order.
        # If order is important, all the platform's files must have a merge order in the filename.
        # If order is not important, the base config filename must end in '.config.yml' (e.g. platform.config.yml) and
        # the platform's other filenames platform.some-descriptive-name.config.yml (e.g. platform.casespace.config.yml).
        # Be sure to remove or rename any old/alternative/testing/etc. config files.
        def set_platform_configurations
          @all_platform_configurations = ActiveSupport::OrderedOptions.new
          platform_names_processed     = Array.new
          platform_configs             = get_platform_configs_with_merge_configs
          platform_configs.each_pair do |orig_platform_name, merge_configs|
            previous_configs_for_debug = []
            current_platform_path      = nil
            current_platform_name      = nil
            # merge_configs is a hash:
            #  key   = merge order value
            #  value = filename
            # Sort the merge config keys in merge ascending order.  Base config will be first.
            merge_configs.keys.sort.each do |merge_order|
              file          = merge_configs[merge_order]
              file_contents = File.read(file)
              config        = HashWithIndifferentAccess.new( YAML.load(file_contents) )
              platform_name, platform_path = get_platform_name_and_path_from_config(orig_platform_name, config)
              current_platform_path ||= platform_path
              current_platform_name ||= platform_name
              unless (current_platform_name == platform_name && current_platform_path == platform_path)
                error "Platform path [#{current_platform_path}] has path mis-match [#{platform_path}] in config file [#{file}]"
              end
              platform_config = platform_configurations[platform_name] ||= ActiveSupport::OrderedOptions.new
              platform_config.platform_name = platform_name
              platform_config.platform_path = platform_path
              process_platform_config(platform_config, config)
              merge_config_debug_message(file, previous_configs_for_debug) unless ::Rails.env.production?
            end
            error "Duplicate platform name [#{current_platform_name}] in config [#{orig_platform_name}]"  if platform_names_processed.include?(current_platform_name)
            platform_names_processed.push current_platform_name
          end
          resolve_path_references  # resolve any cross platform references
          basic_validation
        end

        def get_platform_name_and_path_from_config(orig_platform_name, config)
          name = config[:platform_name]
          path = config[:platform_path]
          case
          when name.present? && path.present?  # verify they are correct
            path_name = path.to_s.gsub(/\//, '_')
            error "Platform path [#{path}] does not match platform name [#{name}] in [#{orig_platform_name}]"  unless path_name == name
          when name.blank? && path.present?
            name = path.to_s.gsub(/\//, '_') # best to specify the path rather than only the name
          when name.present? && path.blank?
            path = name.to_s.gsub('_', '/')  # best guess; will be incorrect if each word is not a path (e.g. a_b_c_d -> a/b/c/d but should be a/b_c/d)
            warning "Platform path [#{path.inspect}] assumed from platform name [#{name.inspect}].  Best to use the 'platform_path' key"
          when name.blank? && path.blank?
            name = orig_platform_name.to_s
            path = name.gsub('_', '/')  # see comment above for possible errors
            warning "Platform path [#{path.inspect}] assumed from platform name [#{name.inspect}] (taken from filename).  Best to use the 'platform_path' key"
          end
          return [name.to_s.downcase, path.to_s.downcase]
        end

        def get_platform_configs_with_merge_configs
          file_ext = totem_settings.option.configuration_file_extension
          error "The configuration_file_extension has not been set"  if file_ext.blank?
          search_dirs = totem_settings.option.configuration_file_directory_search
          error "The configuration_file_directory_search has not been set"  if search_dirs.blank?
          filename     = totem_settings.option.configuration_files_filename
          relative_to  = totem_settings.option.configuration_files_relative_to
          config_files = shared_configuration_files(search_dirs, file_ext, filename: filename, relative_to: relative_to)
          error "No config files found"  if config_files.blank?
          platform_configs = Hash.new
          merge_count      = Hash.new(0)
          config_files.sort.each do |file|
            basename       = File.basename(file, '.config.yml')
            basename_parts = basename.split(/\./)
            platform_name  = basename_parts.shift
            merge_order    = basename_parts.shift
            if merge_order.present?
              if merge_order.match(/\D/)  # non numeric merge order
                merge_order = (merge_count[platform_name] += 1).to_s.rjust(4,'0')
              end
            else
              merge_order = platform_configs[platform_name].blank? ? '0000' : (merge_count[platform_name] += 1).to_s.rjust(4,'0')
            end
            platform_configs[platform_name] ||= Hash.new
            has_file = platform_configs[platform_name][merge_order]
            error "Config file [#{file}] has a merge order [#{merge_order}] which duplicates file [#{has_file}]"  if has_file.present?
            platform_configs[platform_name][merge_order] = file
          end
          platform_configs
        end

        def merge_config_debug_message(file, files)
          file_path = Pathname.new(file).relative_path_from(Rails.root).to_s.sub(/\.config\.yml$/, '')
          if files.blank?
            debug "Processing config file [#{file_path}]"
          else
            last_file_path = Pathname.new(files.last).relative_path_from(Rails.root).to_s.sub(/\.config\.yml$/, '')
            debug "Merging config file [#{file_path}] with config [#{last_file_path}]"
          end
          files.push file
        end

        # ######################################################################################
        # @!group Platform Configuration Values

        def process_platform_config(platform_config, config)
          platform_config.classes        = simple_key_merge(:classes, platform_config, config)
          platform_config.modules        = simple_key_merge(:modules, platform_config, config)
          platform_config.routes         = simple_key_merge(:routes, platform_config, config)
          platform_config.authentication = get_authentication(platform_config, config)
          platform_config.authorization  = simple_key_merge(:authorization, platform_config, config)
          platform_config.model_access   = simple_merge(:model_access, platform_config, config)
          platform_config.seed_order     = get_seed_order(platform_config, config)
          platform_config.paths          = get_paths(platform_config, config)  # do last since uses other values such as routes
        end

        # ######################################################################################
        # @!group Authentication

        def get_authentication(platform_config, config)
          authentication          = simple_key_merge(:authentication, platform_config, config)
          config_session          = (config[:authentication] || Hash.new)[:session] || Hash.new
          platform_config_session = (platform_config[:authentication] || Hash.new)[:session] || Hash.new
          session                 = config_session.deep_merge(platform_config_session)
          authentication.session  = convert_key_time_values_to_numeric_seconds(session)
          authentication
        end

        # ######################################################################################
        # @!group Seed Order

        # Combine seed order arrays together.
        def get_seed_order(platform_config, config)
          config_seed_order = config[:seed_order]
          seed_order = [ platform_config[:seed_order], config_seed_order ].flatten.compact.uniq
          # allow empty seed_order array to mean 'no' seed order rather than default to paths
          return nil if config_seed_order.nil? && seed_order.blank?
          seed_order
        end

        # ######################################################################################
        # @!group Platform Paths

        def get_paths(platform_config, config)
          platform_paths = platform_config[:paths] || Array.new
          config_paths   = config[:paths]          || Array.new
          platform_paths = Array.new if config_paths.present? && override_paths(config)

          # Temporarily store all of this configs's paths and their values so can expand wildcard paths
          temp_values = Hash.new    # temp store of the path values by path key
          temp_paths  = Array.new

          config_paths.each do |path_hash|
            path_hash ||= Hash.new
            path        = path_hash[:path]
            error "Platform [#{platform_config.platform_name}] entry does not have a path value [#{path_hash}]"  if path.blank?
            temp_paths.push path
            temp_values[path] = path_hash
          end
          all_paths = shared_expand_wildcard_engine_paths(temp_paths)  # expand any wildcard paths into each path

          all_paths.each do |path|
            path_config = ActiveSupport::OrderedOptions.new
            path_hash   = temp_values[path] || wildcard_path_values(path, temp_paths, temp_values) || {}
            engine_name = shared_engine_path_to_engine_name(path)
            path_config.path         = path
            path_config.is_engine    = totem_settings.engine.find_by_name(engine_name).present?
            path_config.is_reference = true  unless path.starts_with?(platform_config.platform_path.to_s)
            path_config.engine_name  = engine_name  if path_config.is_engine
            path_config.routes       = get_path_route_values(platform_config, path_config, path_hash)

            platform_paths.push path_config  # add each to path config to the array
          end
          platform_paths
        end

        def wildcard_path_values(path, paths, values)
          paths.each do |match_path|
            next unless match_path.ends_with?('*')
            return values[match_path]  if path.starts_with?(match_path.chop)
          end
          nil
        end

        def override_paths(config)
          config[:override_paths] == true
        end

        # ######################################################################################
        # @!group Path Routes

        # Merges any main :routes section values into the path routes.
        def get_path_route_values(platform_config, path_config, path_hash)
          routes          = ActiveSupport::OrderedOptions.new
          path_routes     = (path_hash[:routes] || HashWithIndifferentAccess.new).deep_dup
          platform_routes = platform_config[:routes] || Hash.new
          validate_is_blank_or_hash(path_routes, :mount, platform_config, path_config)
          validate_is_blank_or_hash(path_routes, :match, platform_config, path_config)
          routes.mount    = simple_merge_ordered_hash(:mount, path_routes, platform_routes)
          routes.match    = simple_merge_ordered_hash(:match, path_routes, {})  # do not inherit match values from platform
          routes.url      = (path_hash[:routes] && path_hash[:routes][:url]) || platform_routes[:url]
          remove_blank_path_routes_values(routes, path_routes) if path_config.is_reference
          routes
        end

        def validate_is_blank_or_hash(values, key, platform_config, path_config)
          return if values[key].blank? || values[key].kind_of?(Hash)
          platform_name = platform_config[:platform_name]
          path          = path_config.path
          error "Platform #{platform_name.inspect} path #{path.inspect} is not blank or a hash."
        end

        # Remove any keys with blank value that were inherited from the platform.
        # Allow the reference to populate them.
        def remove_blank_path_routes_values(routes, path_routes)
          routes.delete(:mount)  if path_routes[:mount].blank?
          routes.delete(:match)  if path_routes[:match].blank?
          routes.delete(:url)    if path_routes[:url].blank?
        end

        # ######################################################################################
        # @!group Resolve Path References

        # Performed after all the configurations have been processed.
        # The referenced platform values are duplicated and inserted into the platform's values.

        def resolve_path_references
          platform_configurations.each_key do |platform_name|
            platform_paths = paths(platform_name) || Array.new
            platform_paths_dup_check = Array.new
            platform_paths.each do |path_config|
              path = path_config.path
              if platform_paths_dup_check.include?(path)
                error "Platform #{platform_name.inspect} has a duplicate path #{path.inspect}."
              else
                platform_paths_dup_check.push(path)
              end
              next unless path_config.is_reference
              validate_engine_path_and_engine_class(path)  if path_config.is_engine  # check to make sure engine name matches its class
              ref_platform_path = path.split('/')
              ref_platform_path.pop  # remove the sub platform name and leave the platform name
              ref_platform_name = ref_platform_path.join('_')
              if (ref_platform = platform(ref_platform_name)).blank?
                error "Platform [#{platform_name.inspect}] has a reference to path [#{path}] that can not be resolved"
              end
              ref_config = ref_platform.paths.select{|p| p.path == path}.first
              error "Reference in platform [#{platform_name.inspect}] for [#{path}] not found in [#{ref_platform_name}]"  if ref_config.blank?
              new_config = ref_config.deep_merge(path_config)
              path_config.deep_merge! new_config.merge(is_reference: true)
            end
          end
        end

        # ######################################################################################
        # @!group Validation

        def basic_validation
          # possibly do something here in the future
          basic_path_validation
        end

        def basic_path_validation
          platform_configurations.each_key do |platform_name|
            platform_paths = paths(platform_name) || Array.new
            platform_paths.each do |path_config|
              if path_config.is_engine
                if totem_settings.engine.loaded?(path_config.engine_name)
                  validate_engine_path_and_engine_class(path_config.path) # check to make sure engine name matches its class
                else
                  warning "Platform [#{platform_config.platform_name}] includes path [#{path_config.path}] but the engine is not loaded"
                end
              end
              if path_config.routes.url.nil?
                warning "Platform [#{platform_name}] url value is blank for path [#{path_config.path}]"  unless platform_name == :totem
              end
            end
          end
        end

        # Validate an engine's path matches the engine's class (totem/core engine defined as Totem::Core)
        def validate_engine_path_and_engine_class(path)
          engine_class = totem_settings.engine.name_and_class[shared_engine_path_to_engine_name(path)]
          if engine_class.blank?
            error "Engine path [#{path.inspect}] does not exist"
          end
          if engine_class.underscore != path
            error "Engine path [#{path.inspect}] does not match engine class [#{engine_class}]"
          end
        end

        # ######################################################################################
        # @!group Helpers
        # Convert a hash string time value(s) to a Rails Fixnum seconds object e.g. '10.minutes'
        def convert_key_time_values_to_numeric_seconds(hash)
          hash.each_pair do |key, value|
            next unless key.to_s.ends_with?('_time')
            next if value.is_a?(Fixnum)
            i, time_units = value.split('.', 2) # e.g. 10, minutes
            i = i.to_i
            error("Invalid authentication session time value for key [#{key.inspect}] value [#{value.inspect}].")  if i <= 0
            error("Invalid authentication session time_unit value for key [#{key.inspect}] value [#{value.inspect}].")  unless i.respond_to?(time_units)
            hash[key] = i.send(time_units)
          end
          hash
        end

        # Can use when all keys are standard ruby variable names, otherwise use simple_merge.
        # If use this on keys like 'platform/assignment' will need to symbolize the string and use []
        # (e.g. config.model_access['isu/vet_med/ts'.to_sym]).
        def simple_key_merge(key, platform_config, config)
          hash = Hash[(config[key] || Hash.new).deep_merge(platform_config[key] || Hash.new)]
          ActiveSupport::OrderedOptions[hash.deep_symbolize_keys]
        end

        def simple_merge(key, platform_config, config)
          HashWithIndifferentAccess[(config[key] || Hash.new).deep_merge(platform_config[key] || Hash.new)]
        end

        def simple_merge_ordered_hash(key, platform_config, config)
          ActiveSupport::OrderedHash[(config[key] || Hash.new).deep_merge(platform_config[key] || Hash.new)]
        end

        include Shared

      end
    end
  end
end
