# See end of file for documentation.
module Totem
  module Core
    module Routes
      class Engines

        attr_reader :totem_settings

        attr_reader :platform_name
        attr_reader :platform_paths
        attr_reader :platform_options

        # Set per path:
        attr_reader :path_url
        attr_reader :engine_path

        MOUNT_OPTIONS = [:at, :via, :as, :path, :constraints, :module, :to, :on, :defaults, :anchor, :format, :controller, :action].freeze
        MATCH_OPTIONS = [:via, :to, :at, :path, :constraints, :controller, :action, :module, :as, :on, :defaults, :anchor, :format].freeze

        def initialize(defaults={})
          @defaults = defaults
        end

        # Main entry point of route concern.
        def call(mapper, options={})
          @platform_options = @defaults.merge(options)
          @totem_settings   = platform_options.delete(:env) || ::Totem::Settings
          @platform_name    = platform_options.delete(:platform_name)
          error "No platform name provided for routes"  unless @platform_name.present?
          @platform_paths = totem_settings.config.paths(platform_name)
          error "No configuration paths for platform [#{platform_name}]"  unless platform_paths.present?
          process_routes_for_platform_paths(mapper)
          add_platform_match_routes(mapper)
        end

        # Process the platform's 'paths' (e.g. engine paths).
        def process_routes_for_platform_paths(mapper)
          platform_paths.each do |path_config|
            next unless path_config.is_engine
            engine_name = path_config.engine_name
            engine      = totem_settings.engine.name_and_engine[engine_name]
            error "No engine with name [#{engine_name}]"  unless engine.present?
            next unless has_routes?(engine)  # no config/routes.rb
            @engine_path = engine_to_path(engine)
            @path_url    = path_config.routes && path_config.routes.url
            mount_engine(engine, mapper, path_config)
            add_path_match_routes(mapper, path_config)
          end
        end

        # ######################################################################################
        # @!group Mount Engine

        def mount_engine(engine, mapper, path_config)
          mount_options = path_config.routes && path_config.routes.mount
          error "Platform #{platform_name.inspect} path #{path_config.path.inspect} mount options must be a hash"  unless mount_options.kind_of?(Hash)
          route_options = get_route_options(MOUNT_OPTIONS, mount_options)
          route_options[:at] ||= '/'  # default to / if not specified
          debug "Mounted engine [#{path_config.path}] with options #{print_debug_route_options(MOUNT_OPTIONS, route_options)}"
          mapper.mount engine.class, route_options
        end

        # ######################################################################################
        # @!group Match Routes

        def add_path_match_routes(mapper, path_config)
          matches = path_config.routes && path_config.routes.match
          return if matches.blank?
          error "Platform #{platform_name.inspect} path #{path_config.path.inspect} matches must be a hash"  unless matches.kind_of?(Hash)
          add_match_routes(mapper, matches, path_config.path)
        end

        def add_platform_match_routes(mapper)
          platform_routes = totem_settings.config.routes(platform_name)
          return if platform_routes.blank?
          matches = platform_routes[:match]
          return if matches.blank?
          error "Platform #{platform_name.inspect} routes: match: must be a hash #{matches.inspect}"  unless matches.kind_of?(Hash)
          add_match_routes(mapper, matches, platform_name)
        end

        def add_match_routes(mapper, matches, name)
          matches.each do |match, match_options|
            # match_options = add_match_self_path_constraint(match)  if match_options.nil?  # may not want to do this
            error "Platform #{platform_name.inspect} match #{match.inspect} options must be a hash"  unless match_options.kind_of?(Hash)
            route_options       = get_route_options(MATCH_OPTIONS, match_options)
            route_options[:via] = [route_options[:via] || :get].flatten.compact.collect{|v| v.to_s.downcase.to_sym}
            debug "Match route [#{match.to_s}] added by [#{name}] with options #{print_debug_route_options(MATCH_OPTIONS, route_options)}"
            mapper.match match.to_s, route_options
            if match.to_s.start_with?('*')  # glob route
              glob_options = route_options.merge(platform_name: platform_name)
              totem_settings.registered.add_engine_glob_route(glob_options)
            end
          end
        end

        # ######################################################################################
        # @!group Route Options

        # Extracts only the valid keys.
        def get_route_options(keys, source_options)
          validate_option_keys(keys, source_options)
          route_options = Hash.new
          options       = source_options.deep_dup.symbolize_keys
          keys.each do |key|
            route_options[key] = options[key] if options.has_key?(key)
          end
          set_constraints_in_route_options(route_options)
          route_options.delete(:constraints)  if route_options[:constraints].blank?
          route_options
        end

        # ######################################################################################
        # @!group Route Constraints

        def set_constraints_in_route_options(route_options)
          route_constraints = route_options[:constraints]
          if route_constraints == false
            route_options[:constraints] = {}
            return
          end
          
          route_constraints = (route_constraints || Hash.new).symbolize_keys

          # remove non-standard Rails constraint keys
          add_paths               = route_constraints.delete(:add_paths)
          include_engine_path     = route_constraints.delete(:engine_path)
          add_engine_paths        = route_constraints.delete(:add_engine_paths)
          include_engine_url_path = route_constraints.delete(:engine_url_path)
          add_engine_url_paths    = route_constraints.delete(:add_engine_url_paths)

          # If remaining constraint is a regexp (e.g. starts and ends with /), convert to regexp.
          # Do not process the path yet.
          route_constraints.except(:path).each do |key, value|
            if value.kind_of?(String) && value.start_with?('/') && value.end_with?('/')  # is in a regex format
              regex_value = value.sub(/^\//,'').sub(/\/$/,'')
              route_constraints[key] = /#{regex_value}/
            end
          end

          # If a path is already present, then ignore adding any addition constraints.
          if (path_constraint = route_constraints[:path]).present?
            route_constraints[:path]    = /#{path_constraint}/
            route_options[:constraints] = route_constraints
            return
          end

          # Fully qualified paths (e.g. engine's path no added).
          add_paths = [add_paths].flatten.compact

          # Prefix engine paths with the engine's path.
          path_urls  = (include_engine_path == true) ? ['/' + engine_path] : []
          path_urls += [add_engine_paths].flatten.compact.collect {|p| get_path_url_with_leading_slash(engine_path, p)}

          # Prefix engine url paths (e.g. api) with the url and engine's path.
          path_urls += (include_engine_url_path == false) ? [] : [ get_path_url_with_leading_slash(path_url, engine_path) ]
          path_urls += [add_engine_url_paths].flatten.compact.collect {|p| get_path_url_with_leading_slash(path_url, engine_path, p)}

          all_paths = add_paths + path_urls

          error "Engine path #{engine_path.inspect} did not generate any route constraints" if all_paths.blank?
          constraint = join_multiple_urls(all_paths.uniq)
          route_constraints.merge!( path: /#{constraint}/ )  # add path constraint as regex
          route_options[:constraints] = route_constraints
        end

        # Only used if start allowing nil match paths.  Currently cannot be nil.
        def add_match_self_path_constraint(match)
          match_options = Hash.new
          match_options[:constraints] = Hash.new
          match_options[:constraints][:path] = '/' + match
          match_options
        end

        # ######################################################################################
        # @!group Helpers

        # Validate keys in the _OPTIONS constants).
        def validate_option_keys(keys, options)
          unknown_keys = options.symbolize_keys.keys - keys
          error "Unknown route options keys #{unknown_keys.inspect}"  if unknown_keys.present?
        end

        # Just print the options in a logical order (order specified in the _OPTIONS constants).
        def print_debug_route_options(keys, route_options)
          print_hash = ActiveSupport::OrderedHash.new
          keys.each do |key|
            print_hash[key] = route_options[key]  if route_options.has_key?(key)
          end
          print_hash.inspect
        end

        def get_path_url_with_leading_slash(*args)
          get_path_url(args.unshift(''))
        end

        def get_path_url(*args)
          [args].flatten.compact.join('/')
        end

        def engine_to_path(engine)
          engine.class.to_s.deconstantize.underscore
        end

        def join_multiple_urls(urls)
          return urls.first if urls.length < 2
          '(' + urls.collect{|u| u.strip}.join('|') + ')'
        end

        def has_routes?(engine)
          return false unless engine.respond_to?(:routes)
          route_path = engine.paths['config/routes.rb']
          return false unless route_path
          File.exists?(route_path.first)
        end

        include ::Totem::Core::Support::Shared

      end

    end
  end
end

# The 'routes' section exists at the platform level and at the path level.
# A routes-section can have primary keys :mount, :match, :url.
#
# mount: [Hash] mount options for the engine path.
#:       Accepts the standard Rails mount options (see MOUNT_OPTIONS).
#:       Platform level mount options when supplied are inherited by the paths (e.g. engines).
#
# match: [Hash] route as the key with value a hash of match options.
#:       Accepts the standard Rails match options (see MATCH_OPTIONS).
#:       Platform matches are added 'after' all path matches (e.g. can be used for a glob route).
#
# url: [String] added to paths for url based routes.
#:     The path url is inherited from the platform unless specified in a path's routes.
#
# The options hash keys are standard Rails options except for the 'constraints' key
# which may include some non-standard keys.
#
# constraints: [Hash|false] constraint options to be added to the route.
#:             Defaults to the url path route (unless the constraint hash contains a 'path' key,
#:             then all other constraints are ignored and the path value used.)
#:             When 'false' no constraints are added (e.g. on a public or glob route).
#:             Constraints are added with 'OR' operator (e.g. constraint1|constraint2|...).
#
# Non-standard constraint keys (they are deleted from the options hash before adding the route):
#
# add_paths:            [String|Array of Strings] add the routes as-is with no engine scoping.
# engine_path:          [true|FALSE] includes the engine path (e.g. without the url prefix).
# add_engine_paths:     [String|Array of Strings] adds routes with an engine path prefix.
# engine_url_path:      [TRUE|false] includes engine url route (e.g. url/engine-path)
# add_ingine_url_paths: [String|Array of Strings] adds routes with the url and engine path prefix.
#                   
# Example:                         
#   - path: test/plaform/one
#     routes:
#       url:   'api'  (will inherit from platform if not specified)
#       mount:
#         at: '/'     ('/' is also the default)
#         constraints:
#           engine_path:          true
#           engine_url_path:      true
#           add_paths:            [sign_in, /sign_out]
#           add_engine_paths:     [user, profile]
#           add_engine_url_paths: [stats, history]
#
#   Resulting constraint path regex (without backslash delimiters):
#     :path=>/(sign_in|/sign_out|/test/platform/one/user|/test/platform/one/profile|/test/platform/one|/test/platform/one/stats|/test/platform/one/history)/
