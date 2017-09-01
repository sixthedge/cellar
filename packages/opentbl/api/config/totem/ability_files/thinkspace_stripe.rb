module Thinkspace; module Authorization
class ThinkspaceStripe < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def stripe
    stripe = get_class 'Thinkspace::Stripe::Customer'
    return if stripe.blank?
    customer = Thinkspace::Stripe::Customer
    can [:create, :update, :cancel, :reactivate, :subscription_status], customer
  end

end; end; end
