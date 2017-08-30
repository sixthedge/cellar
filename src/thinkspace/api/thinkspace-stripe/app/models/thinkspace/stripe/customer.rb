module Thinkspace
  module Stripe
    class Customer < ActiveRecord::Base
      totem_associations 
      validates_uniqueness_of :ownerable_id, scope: [:ownerable_type]

      def self.has_stripe_customer?(ownerable)
        return ownerable.thinkspace_stripe_customer.present?
      end

      def self.get_ts_customer(ownerable)
        return nil unless self.has_stripe_customer?(ownerable)
        return ownerable.thinkspace_stripe_customer
      end

      def self.create_customer(ownerable, token)
        tsc = self.new(ownerable: ownerable)
        ## TODO: Remove this
        temp_email = 'dylanbel7+test7@gmail.com'

        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts tsc
        puts tsc.inspect
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'
        puts '********************TSC TSC TSC***********************'


        options = {
          email: temp_email,
          description: "Customer for #{ownerable.email}",
          source: token
        }

        sc = ::Stripe::Customer.create(options)

        tsc.sync_from_stripe_customer!(sc)
        return tsc, sc
      end

      def self.update_customer(ownerable, token)
        tsc = self.find_by(ownerable: ownerable)
        sc  = ::Stripe::Customer.retrieve(tsc.customer_id)

        sc.source = token
        sc.save
        return tsc, sc
      end

      def self.create_subscription(ownerable, plan_id, token)
        tsc, sc = self.create_customer(ownerable, token)
        options = {
          customer: tsc.customer_id,
          items: [{plan: plan_id}]
        }

        sub = ::Stripe::Subscription.create(options)
        puts sub
        tsc.sync_from_stripe_subscription!(sub)
      end

      def self.update_subscription(ownerable, plan_id, token)
        tsc, sc = self.update_customer(ownerable, token) 
        ## Could use plan_id to upgrade/downgrade plans here

        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts '*****************UPDATE SUBSCRIPTION***********************'
        puts tsc, sc

      end

      def self.cancel_subscription(ownerable)
        tsc = self.get_ts_customer(ownerable)
        ## Error here if tsc is false/not present
        sc  = tsc.get_stripe_customer
        sub = sc.subscriptions.data.first
        sub = sub.delete(at_period_end: true)
        sub
      end

      def self.reactivate_subscription(ownerable)
        tsc = self.get_ts_customer(ownerable)
        sc  = tsc.get_stripe_customer
        sub = sc.subscriptions.data.first
        puts '********************REACTIVATING***********************'
        puts '********************REACTIVATING***********************'      
        sub = sub.save
        puts sub
        puts sub.inspect
      end

      def self.create_or_update_subscription(ownerable, plan_id, token)
        ## validate_subscription
        # if has_stripe_customer?(ownerable)
        #   update_subscription(ownerable, plan_id, token)
        # else
        create_subscription(ownerable, plan_id, token)
        # end
      end

      def self.get_subscription_data(ownerable)
        tsc = self.get_ts_customer(ownerable)

        data = {}
        data['has_sub'] = false
        if tsc.present?
          if tsc.status.present? && tsc.current_period_start.present? && tsc.current_period_end.present?
            data['has_sub'] = true
            data['sub']     = {
              status:           tsc.status,
              cur_period_start: tsc.current_period_start,
              cur_period_end:   tsc.current_period_end,
              will_end:         tsc.will_end
            }
          end
        end

        return data
      end

      def self.is_debug?
        false
      end

      def will_end
        sc = self.get_stripe_customer
        sub = sc.subscriptions.data.first
        return sub.cancel_at_period_end
      end

      def subscription_active?
        return subscription_active_statuses.include?(self.status)
      end

      def get_stripe_customer
        return nil unless self.customer_id.present?
        sc = ::Stripe::Customer.retrieve(self.customer_id)
        ## TODO handle errors here
        return sc
      end

      def subscription_active_statuses
        return ['trialing', 'active']
      end

      def sync_from_stripe_customer(customer, save_customer=false)
        self.customer_id = customer.id
        self.save if (save_customer && !self.class.is_debug?)
      end

      def sync_from_stripe_customer!(customer)
        sync_from_stripe_customer(customer, true)
      end

      def sync_from_stripe_subscription(sub, save_customer=false)
        self.status               = sub.status
        self.current_period_start = Time.at(sub.current_period_start)
        self.current_period_end   = Time.at(sub.current_period_end)
        self.save if (save_customer && !self.class.is_debug?)
      end

      def sync_from_stripe_subscription!(sub)
        sync_from_stripe_subscription(sub, true)
      end
    
    end
  end
end
