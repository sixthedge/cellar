module Thinkspace
  module Builder
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Builder     
      engine_name 'thinkspace_builder'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_builder',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'wips',
        )
      end

    end
  end
end
