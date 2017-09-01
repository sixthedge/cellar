module Thinkspace
  module Stripe
    module Api
      class WebhooksController < ::ApplicationController

        def callback
          type_str = parse_event_type(params[:type])
          type     = "Thinkspace::Stripe::Concerns::EventHandlers::#{type_str}"
          klass    = type.safe_constantize

          if klass.present?
            begin 
              klass.new(params).process
              render nothing: true, status: 200
            rescue
              render nothing: true, status: 501
            end
          else
            render nothing: true, status: 501
          end
        end

        private

        ## Type passed in format ex. 'customer.subscription.updated'
        def parse_event_type(type)
          type = type.titleize
          type = type.gsub('.', '::')
          return type
        end

      end
    end
  end
end
