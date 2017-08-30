module Thinkspace; module Stripe; module Concerns; module EventHandlers; module Customer; module Subscription; 
  class Updated < ::Thinkspace::Stripe::Concerns::EventHandlers::Customer::Subscription::Base

    def process
      ## Find relevant customer record in our db
      tsc = get_ts_customer
      sub = get_sub_from_params

      ## Update fields to param values OR update only changed fields
      return unless tsc.present? && sub.present?
      sub = params.dig(:data, :object)
      tsc.current_period_start = Time.at(sub.current_period_start)
      tsc.current_period_end   = Time.at(sub.current_period_end)
      tsc.status               = sub.status
      tsc.save
    end

  end
end; end; end; end; end; end
