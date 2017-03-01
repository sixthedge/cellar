module Thinkspace; module Builder; module Api
  class TemplatesController < Totem::Settings.class.thinkspace.authorization_api_controller
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_serializer_options
    before_action :get_templates_by_templateable_type, only: [:index]

    def index
      controller_render(@templates)
    end

    private

    def get_templates_by_templateable_type
      templateable_type = params[:templateable_type]
      if templateable_type.present?
        templateable_type = templateable_type.classify
        klass             = templateable_type.safe_constantize
        raise_access_denied_exception "Invalid templateable_type [#{templateable_type}] specified for call." unless klass.present?
        @templates = @templates.where(templateable_type: templateable_type)
      end
    end

  end
end; end; end
