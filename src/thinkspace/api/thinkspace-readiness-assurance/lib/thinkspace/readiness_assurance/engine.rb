module Thinkspace
  module ReadinessAssurance
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::ReadinessAssurance
      engine_name 'thinkspace_readiness_assurance'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_readiness_assurance',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end
