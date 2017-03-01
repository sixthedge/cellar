module Thinkspace
  module Casespace
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Casespace     
      engine_name 'thinkspace_casespace'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_casespace',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'wips',
        )
      end

    end
  end
end
