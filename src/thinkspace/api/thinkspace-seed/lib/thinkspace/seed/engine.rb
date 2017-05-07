module Thinkspace
  module Seed
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Seed
      engine_name 'thinkspace_seed'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_seed',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'seed',
        )
      end

    end
  end
end
