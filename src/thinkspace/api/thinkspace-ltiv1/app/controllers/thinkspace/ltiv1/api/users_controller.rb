module Thinkspace; module Ltiv1; module Api;
  class UsersController < ::Totem::Settings.class.thinkspace.authorization_api_controller

    include ::Totem::Settings.module.thinkspace.lti_user_actions

    private

    def handler_class; Thinkspace::Ltiv1::RequestHandler; end

    def get_lti_setup_query_params
      type = space_class.name if @handler.resource_link_is_space?
      type = assignment_class.name if @handler.resource_link_is_assignment?
      {
        email:            @handler.email,
        context_title:    @handler.context_title,
        context_type:     get_truncated_class_name(type),
        consumer_title:   @handler.consumer.title,
        resource_link_id: @handler.resource_link_id,
        user_id:          @handler.user.id,
        auth_token:       @session.authentication_token
      }
    end

    def get_truncated_class_name(name); name.underscore.split('/').pop; end

    def assignment_class; Thinkspace::Casespace::Assignment; end
    def space_class;      Thinkspace::Common::Space;         end

  end
end; end; end