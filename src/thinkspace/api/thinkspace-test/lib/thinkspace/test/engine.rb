module Thinkspace
  module Test
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Test
      engine_name 'thinkspace_test'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_test',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'wips',
        )
      end

    end
  end
end
