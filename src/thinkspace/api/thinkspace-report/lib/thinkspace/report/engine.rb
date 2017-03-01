module Thinkspace
  module Report
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Report
      engine_name 'thinkspace_report'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_report',
          platform_name:  'thinkspace',
          platform_path:  'thinkspace',
          platform_scope: 'thinkspace',
          platform_sub_type: 'report'
        )
      end

    end
  end
end
