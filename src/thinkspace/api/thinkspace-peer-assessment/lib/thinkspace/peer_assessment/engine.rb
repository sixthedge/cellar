module Thinkspace
  module PeerAssessment
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::PeerAssessment
      engine_name 'thinkspace_peer_assessment'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_peer_assessment',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'tools',
        )
      end

    end
  end
end