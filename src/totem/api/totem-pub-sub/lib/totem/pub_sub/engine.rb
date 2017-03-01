module Totem
  module PubSub
    class Engine < ::Rails::Engine

      isolate_namespace Totem::PubSub
      engine_name 'totem_pub_sub'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('totem_pub_sub',
          platform_name:  'totem',
          platform_path:  'totem',
          platform_scope: 'totem',
        )
      end

    end  
  end
end
