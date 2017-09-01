module Thinkspace; module Stripe; module Concerns; module EventHandlers; module Customer; module Subscription; 
  class Deleted < ::Thinkspace::Stripe::Concerns::EventHandlers::Customer::Subscription::Base

    def process
      ## Find relevant customer record in our db
      tsc = get_ts_customer

      ## Update fields to param values OR update only changed fields
      return unless tsc.present?
    end

  end
end; end; end; end; end; end
