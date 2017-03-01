module Totem
  module Authentication
    module Session
      class Engine < ::Rails::Engine

        isolate_namespace Totem::Authentication::Session
        engine_name 'totem_authentication_session'

        initializer 'engine.registration', after: 'framework.registration' do |app|
          ::Totem::Settings.register.engine('totem_authentication_session',
            platform_name:  'totem',
            platform_path:  'totem',
            platform_scope: 'totem',
          )
        end

      end  
    end
  end
end
