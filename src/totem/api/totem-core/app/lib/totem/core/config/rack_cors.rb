module Totem
  module Core
    module Config
      class RackCors

        def self.process(config, options={})
          case
          when ::Rails.env.development?  then development(config, options)
          else                                production(config, options)
          end
        end

        private

        def self.development(config, options)
          config.middleware.insert_before 0, Rack::Cors do
            allow do
              origins '*'
              resource '*', :headers => :any, :methods => [:get, :put, :delete, :post, :options, :patch]
            end
          end
        end

        def self.production(config, options)
          config.middleware.insert_before 0, Rack::Cors do
            allow do
              origins '*'
              resource '*.woff', headers: :any, methods: :get
              resource '*.eot',  headers: :any, methods: :get
              resource '*.svg',  headers: :any, methods: :get
              resource '*.ttf',  headers: :any, methods: :get
              resource '*', :headers => :any, :methods => [:get, :put, :delete, :post, :options]
            end
          end
        end

      end
    end
  end
end
