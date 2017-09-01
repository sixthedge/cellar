module Thinkspace
  module Stripe
    module Api
      class CustomersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@customer)
        end

        def create
          ownerable = current_user
          token     = params.dig(:stripe_token, :id)
          plan_id   = params[:plan_id]

          begin
            is_valid = customer_class.create_or_update_subscription(ownerable, plan_id, token)
          rescue ::Stripe::CardError => e
            body = e.json_body
            err  = body[:error]
            raise_access_denied_exception('Error in card processing.', :create, nil,  user_message: err[:message])
          end
        end

        def update
          controller_render(@customer)
        end

        def cancel
          ownerable = current_user
          is_valid  = customer_class.cancel_subscription(ownerable)

          controller_render_no_content
        end

        def reactivate
          ownerable = current_user
          is_valid  = customer_class.reactivate_subscription(ownerable)

          controller_render_no_content
        end

        def subscription_status
          ownerable = current_user
          data      = customer_class.get_subscription_data(ownerable)

          controller_render_json(data)
        end

        private
        def customer_class; Thinkspace::Stripe::Customer; end

      end
    end
  end
end
