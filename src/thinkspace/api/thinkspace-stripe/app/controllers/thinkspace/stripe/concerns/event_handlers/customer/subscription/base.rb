module Thinkspace; module Stripe; module Concerns; module EventHandlers; module Customer; module Subscription; 
  class Base
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def get_ts_customer
      id = @params.dig(:data, :object, :customer)
      return Thinkspace::Stripe::Customer.find_by(customer_id: id)
    end

    def get_plan_from_params
      plan = @params.dig(:data, :object, :plan)
      return plan
    end

    def get_sub_from_params
      sub = @params.dig(:data, :object)
      return sub
    end

    def mailer_class; Thinkspace::Stripe::CustomerMailer; end

  end
end; end; end; end; end; end
