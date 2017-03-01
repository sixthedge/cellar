module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Action; module Controller

  def room_for(*args); server_event_class.totem_pubsub.room_for(*args); end

  def room_with_ownerable(*args); server_event_class.totem_pubsub.room_with_ownerable(*args); end

  def serializer_options; @serializer_options ||= ::Totem::Settings.class.totem.serializer_options.new(self); end

  def record_json(records); controller_as_json(records); end

  def server_event_class; ::Thinkspace::PubSub::ServerEvent; end

  def action_name; 'phase_actions'; end # used when debugging controller messages

  include ::Totem::Core::Controllers::ApiRender
  include ::Totem::Authorization::Cancan::Controllers::CurrentAbility

end; end; end; end; end; end
