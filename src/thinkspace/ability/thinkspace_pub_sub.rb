module Thinkspace; module Authorization
class ThinkspacePubSub < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def pub_sub
    pub_sub = get_class 'Thinkspace::PubSub::ServerEvent'
    return if pub_sub.blank?
    server_event = Thinkspace::PubSub::ServerEvent
    can [:manage], server_event
  end

end; end; end
