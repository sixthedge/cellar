module Thinkspace
  module PubSub
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::PubSub
      engine_name 'thinkspace_pub_sub'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_pub_sub',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'pub_sub',
        )
      end

    end
  end
end
