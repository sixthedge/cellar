module Thinkspace
  module PubSub
    module Api
      class ServerEventsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class

        def load_messages
          validate_load_message_params
          validate_rooms(get_rooms)
          server_events = controller_model_class.scope_messages(get_rooms, get_start_time, get_end_time).order(created_at: :desc)
          serializer_options.remove_all
          controller_render(server_events)
        end

        def tracker
          unless current_user.superuser?
            access_denied "Unauthorized tracker request." unless can?(:update, authable)
          end
          rooms     = get_rooms
          room_type = get_room_type || 'tracker'
          sid       = pubsub.channel_name + '#' + (get_params[:sid] || '')
          access_denied "Unauthorized tracker request. Socketio id is blank." if sid.blank?
          value = {sid: sid, room_type: room_type}
          if current_user.superuser?
            tracker_authable = current_user
            value[:all_rooms] = true
          else
            tracker_authable = authable
            validate_rooms(rooms, room_type)
          end
          server_event_record_class.new
            .origin(self)
            .authable(tracker_authable)
            .user(current_user)
            .rooms(rooms)
            .event(:tracker)
            .room_event(:tracker)
            .action(:tracker)
            .value(value)
            .publish
          controller_render_no_content
        end

        def timer_cancel
          access_denied "Unauthorized timer cancel request." unless current_user.superuser?
          id = get_params[:id]
          access_denied "Timer cancel id is blank in params." if id.blank?
          se = get_timer_server_event(id)
          access_denied "Server event record with id #{id.inspect} not found." if se.blank?
          publish_timer_cancel(se, id)
          controller_render_no_content
        end

        private

        include PubSub::AuthorizeHelpers
        include PubSub::TimerHelpers

        def get_params; @_permited_params ||= params.permit!.to_h[action_name] || Hash.new; end

        def get_room_type; get_params[:room_type]; end
        def get_rooms;     @server_event_rooms ||= [get_params[:rooms]].flatten.compact; end

        # TODO: Add team based validation rules.
        # TODO: Check for assignment & phase due_at? - Use taa?
        def validate_load_message_params
          access_denied "Must supply rooms to load messages."  if get_rooms.blank?
        end

        def get_start_time
          from_time = get_params[:from_time]
          if from_time.blank?
            if get_params[:from_last_login].present?
              api_session = read_api_session(current_user)
              access_denied "API session is blank." if api_session.blank?
              start_time = api_session.created_at
            else
              ndays      = get_params[:from_days] || 1
              start_time = Time.now.utc - ndays.to_i.days
            end
          else
            start_time = Time.parse(from_time).utc rescue nil
            access_denied "Params start time #{from_time.inspect} is an invalid time format." if start_time.blank?
          end
          start_time
        end

        def get_end_time
          to_time = get_params[:to_time]
          return nil if to_time.blank?
          end_time = Time.parse(to_time).utc rescue nil
          access_denied "Params end time #{to_time.inspect} is an invalid time format." if end_time.blank?
          end_time
        end

        def server_event_record_class; ::Thinkspace::PubSub::ServerEvent::Record; end

        def access_denied(message, user_message='')
          action = (self.action_name || '').to_sym
          model  = @server_event || controller_model_class
          raise_access_denied_exception(message, action, model, user_message: user_message)
        end

      end
    end
  end
end
