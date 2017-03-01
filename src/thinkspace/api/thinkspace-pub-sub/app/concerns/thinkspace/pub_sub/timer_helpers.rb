module Thinkspace; module PubSub; module TimerHelpers

  extend ::ActiveSupport::Concern

  included do

    def get_timer_server_event(id)
      return nil if id.blank? or !id.is_a?(String)
      se_id = id.split('/').last
      return nil if se_id.blank? 
      se    = timer_server_event_class.find_by(id: se_id)
      return nil if se.blank?
      se
    end

    def publish_timer_cancel(se, id)
      se.cancel_timer
      timer_server_event_record_class.new
        .origin(self)
        .authable(se.authable)
        .user(current_user)
        .event(:timer_cancel)
        .timer_settings(type: :cancel, cancel_id: id, user_id: current_user.id)
        .publish
    end

    def timer_server_event_class;        ::Thinkspace::PubSub::ServerEvent; end
    def timer_server_event_record_class; ::Thinkspace::PubSub::ServerEvent::Record; end

  end

end; end; end
