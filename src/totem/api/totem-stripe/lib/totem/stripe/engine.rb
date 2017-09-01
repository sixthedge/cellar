module Totem
  module Stripe
    class Engine < ::Rails::Engine

      isolate_namespace Totem::Stripe
      engine_name 'totem_stripe'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('totem_stripe',
          platform_name:  'totem',
          platform_path:  'totem',
          platform_scope: 'totem',
        )
      end

    end  
  end
end
