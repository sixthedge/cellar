module Thinkspace; module Ltiv1; module Api;
  class ContextsController < ::Totem::Settings.class.thinkspace.authorization_api_controller

    def sync
      email            = params[:email]
      resource_link_id = params[:resource_link_id]
      contextable_type = params[:contextable_type]
      contextable_id   = params[:contextable_id]

      raise_access_denied_exception("No email provided")            unless email.present?
      raise_access_denied_exception("No resource link provided")    unless resource_link_id.present?
      raise_access_denied_exception("No contextable_type provided") unless contextable_type.present?
      raise_access_denied_exception("No contextable_id provided")   unless contextable_id.present?

      @context = Thinkspace::Ltiv1::Context.find_by(email: email, key: 'resource_link_id', value: resource_link_id)
      raise_access_denied_exception("No context found for resource link id #{resource_link_id}") unless @context.present?
      raise_access_denied_exception("Contextable already added for resource link id #{resource_link_id}") if @context.contextable.present?

      klass = contextable_type.classify.safe_constantize
      raise_access_denied_exception("Contextable type #{contextable} cannot be constantized") unless klass.present?
      contextable          = klass.find(contextable_id)
      @context.contextable = contextable

      if @context.save
        controller_render_no_content
      else
        raise_access_denied_exception("Context could not be saved #{@context.inspect}")
      end
    end

  end
end; end; end