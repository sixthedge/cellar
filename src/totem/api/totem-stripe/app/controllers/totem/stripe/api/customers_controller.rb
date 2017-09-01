module Totem
  module Stripe
    module Api
      class CustomersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@customer)
        end

        def index
          controller_render(@customer)
        end

        def create
          controller_render(@customer)
        end

        def update
          controller_render(@customer)
        end

      end
    end
  end
end