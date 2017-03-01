module Thinkspace
  module PubSub
    module Api
      class TimersController < ::Totem::Settings.class.totem.application_controller
        respond_to :json

        def reload
          validate_request_url
          timers = server_event_class.scope_timers_by_gt_time(get_end_at)
          json   = {timers: timers.length}
          controller_render_json(json)
          server_event_republish_class.new.republish(timers)
        end

        private

        include ::Totem::Settings.module.totem.controller_api_render

        def get_params; params.permit!.to_h; end

        def get_end_at
          end_at = get_params[:end_at]
          return Time.now.utc if end_at.blank?
          end_at = Time.parse(end_at).utc rescue nil
          access_denied "Params end time #{end_at.inspect} is an invalid time format." if end_at.blank?
          end_at
        end

        # TODO: Validate request url host.
        def validate_request_url
          # access_denied "Invalid remote request."
        end

        def remote_ip;   request.remote_ip; end
        def remote_addr; request.remote_addr; end

        def server_event_class;           ::Thinkspace::PubSub::ServerEvent; end
        def server_event_record_class;    ::Thinkspace::PubSub::ServerEvent::Record; end
        def server_event_republish_class; ::Thinkspace::PubSub::ServerEvent::RePublish; end

        # ###
        # ### Access Denied.
        # ###

        def access_denied(message); raise AccessDenied, message; end

        class AccessDenied < StandardError; end

        rescue_from AccessDenied do |e|
          hash               = Hash.new
          hash[:message]     = e.message
          hash[:subject]     = self.class.name
          hash[:action]      = (self.action_name || '').to_sym
          hash[:remote_ip]   = remote_ip
          hash[:remote_addr] = remote_addr
          render json: {errors: hash}, status: 423
        end

      end
    end
  end
end
