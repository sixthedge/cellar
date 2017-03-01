module Thinkspace
  module Team
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Team
      engine_name 'thinkspace_team'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_team',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'team',
        )
      end

    end
  end
end