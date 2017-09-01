module Thinkspace
  module Ltiv1
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Ltiv1
      engine_name 'thinkspace_ltiv1'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_ltiv1',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace'
        )
      end

    end
  end
end
