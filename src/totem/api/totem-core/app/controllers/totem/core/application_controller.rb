module Totem
  module Core

    class ApplicationController < ActionController::Base

      def serve_index_from_redis
        glob_routes   = ::Totem::Settings.registered.engine_glob_routes
        glob_route    = glob_routes.first
        platform_name = glob_route[:platform_name]
        redis         = Redis.new(url: Rails.application.secrets.redis_url)
        version = params[:version]
        if version.present?
          index = redis.get("#{version}")
        else
          # Get the current revision from Redis.
          # => Will return as something like "default" or "ac1234"
          version = redis.get("#{platform_name}:index:current")
          # The actual HTML is keyed as "platform_name:index:version"
          index   = redis.get("#{platform_name}:index:#{version}")
        end
        redis.disconnect!
        render text: index
      end

      private

      def serializer_options
        @serializer_options ||= new_serializer_options
      end

      def reset_serializer_options
        @serializer_options = new_serializer_options
      end

      def new_serializer_options
        defaults = ::Totem::Settings.authorization.current_serializer_defaults(self) || {}
        # Pass in the controller and the defaults to serializer options class.
        ::Totem::Settings.class.totem.serializer_options.new(self, defaults)
      end
      
    end

  end
end
