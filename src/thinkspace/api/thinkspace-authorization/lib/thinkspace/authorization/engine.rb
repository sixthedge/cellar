require 'cancan'

module Thinkspace
  module Authorization
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Authorization
      engine_name 'thinkspace_authorization'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_authorization',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'authorization',
        )
      end

    end
  end
end
