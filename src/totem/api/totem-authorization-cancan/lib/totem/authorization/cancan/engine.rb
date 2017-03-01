require 'cancan'

module Totem
  module Authorization
    module Cancan
      class Engine < ::Rails::Engine

        isolate_namespace Totem::Authorization::Cancan
        engine_name 'totem_authorization_cancan'

        initializer 'engine.registration', after: 'framework.registration' do |app|
          ::Totem::Settings.register.engine('totem_authorization_cancan',
            platform_name:  'totem',
            platform_path:  'totem',
            platform_scope: 'totem',
          )
        end
  
      end
    end
  end
end
