module Totem
  module Core
    module Routes
      class Invalid

        def initialize(defaults={})
          @defaults = defaults
        end

        # Route example: match '*invalid', via: :all, to: lambda { |env| [  404, {}, [{error: 'invalid request'}.to_json]  ]}
        #
        # The invalid route must be within the engine's 'scope' block and be the last route.
        # If placed outside the 'scope' block, it will match 'all' routes and routes will become invalid.
        #
        # Example:
        #   scope path: '/totem/authentication' do
        #     resources :users, only: [:show]
        #     concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
        #   end
        #   
        def call(mapper, options={})
          options   = @defaults.merge(options)
          route     = options[:route]                || '*invalid'
          status    = options.delete(:status)        || 404
          via       = options.delete(:via)           || :all
          error_msg = options.delete(:error_message) || 'invalid request'

          payload   = {}
          payload[:error] = error_msg
          if Rails.env.development?  # add which engine's routes caused the error
            route_source = mapper.instance_variable_get(:@scope)
            route_source = route_source[:path] if route_source.present?
            payload[:route_source] = route_source || 'unknown'
          end

          error("No invalid route was provided in options [#{options.inspect}]")    if route.blank?
          error("Invalid route does not start with '*' [#{route.inspect}]")         unless route.starts_with?('*')
          error("Invalid route cannot be only '*' [#{route.inspect}]")              if route == '*'
          
          mapper.match route, via: via, to: lambda { |env| [ status, {}, [payload.to_json] ] }
        end

        include ::Totem::Core::Support::Shared

      end
    end
  end
end