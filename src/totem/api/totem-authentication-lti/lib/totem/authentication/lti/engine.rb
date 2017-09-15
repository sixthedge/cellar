module Totem
  module Authentication
    module Lti
      class Engine < ::Rails::Engine

        isolate_namespace Totem::Authentication::Lti
        engine_name 'totem_authentication_lti'

        initializer 'engine.registration', after: 'framework.registration' do |app|
          ::Totem::Settings.register.engine('totem_authentication_lti',
            platform_name:  'totem',
            platform_path:  'totem',
            platform_scope: 'totem',
          )
        end

      end  
    end
  end
end
