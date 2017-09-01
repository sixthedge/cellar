module Thinkspace; module Stripe; module Concerns; module EventHandlers; module Customer; module Subscription; 
  class Created < ::Thinkspace::Stripe::Concerns::EventHandlers::Customer::Subscription::Base

    def process
      ## Find relevant customer record in our db
      tsc  = get_ts_customer
      plan = get_plan_from_params

      ## Update fields to param values OR update only changed fields
      return unless tsc.present? && plan.present?
    end

  end
end; end; end; end; end; end
