module Totem
  module Core
    module Routes
      class Draw

        def draw(routes)
          @routes    = routes
          root_route = nil

          get_platforms.each do |name|
            sym_name = name.to_sym
            @routes.concern sym_name, Totem::Core::Routes::Engines.new(platform_name: name); @routes.concerns [sym_name]
            config_root_route = get_platform_config_root_route(name)
            root_route        = config_root_route if config_root_route.present?
          end

          add_root_route(root_route) if root_route.present?
        end

        private

        def get_platforms
          platforms = (::Totem::Settings.registered.platforms || Array.new).compact
          raise "routes.rb platforms are blank." if platforms.blank?
          platforms
        end

        def get_platform_config_root_route(name)
          (::Totem::Settings.config.routes(name) || Hash.new)[:root]
        end

        def add_root_route(root_route)
          root_route = {to: root_route} if root_route.is_a?(String)
          raise "route.rb root route is not a hash #{root_route.inspect}" unless root_route.is_a?(Hash)
          @routes.root root_route
        end

      end
    end
  end
end
