module Thinkspace; module Authorization; class AbilityEngine

  attr_reader :ability, :current_user

  def initialize(ability)
    @ability      = ability
    @current_user = ability.user
  end

  def process
    raise "Ability class #{self.class.name.inspect} did not implement the 'process' method."
  end

  private

  delegate :admin?,                 to: :ability
  delegate :read_space_ids,         to: :ability
  delegate :admin_space_ids,        to: :ability

  delegate :iadmin?,                to: :ability
  delegate :admin_institution_ids,  to: :ability

  delegate :can,    to: :ability
  delegate :cannot, to: :ability

  delegate :alias_action, to: :ability

  def admin_ability?; admin? || iadmin?; end

  def get_class(class_name); class_name.safe_constantize; end

  def get_private_methods; self.private_methods(false); end

  def call_private_methods; get_private_methods.each {|method| self.send(method)}; end

  def ns_exists?(*args)
    return true if args.blank?
    args.each do |klass|
      class_name = klass.is_a?(String) ? klass : klass.name
      return false if get_class(class_name).blank?
    end
    true
  end
  alias :ns_exist? :ns_exists?

end; end; end
