module Thinkspace; module PeerAssessment; module Api;
  # # assessment_templates
  # - Type: **Controller**
  # - Engine: **thinkspace-peer-assessment**
  class AssessmentTemplatesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_serializer_options

    # ## Endpoints
    # - `index`
    # - `show`
    # - `user_templates`
    # - `select`
    # - `create`
    def index
      controller_render(@assessment_templates.where(state: 'system'))
    end

    def show
      controller_render(@assessment_template)
    end

    def user_templates
      user_id = params[:user_id]
      user    = Thinkspace::Common::User.find(user_id)

      permission_denied("User id provided does not match current user's id") unless user.id == current_user.id
      controller_render(@assessment_templates.where(ownerable_type: 'Thinkspace::Common::User', ownerable_id: current_user.id, state: 'user'))
    end

    def select
      @assessment_templates = @assessment_templates.where(id: params[:ids])
      controller_render(@assessment_templates)
    end

    def create      
      ownerable = Thinkspace::Common::User.find(current_user.id)

      @assessment_template.value     = params_root[:value]
      @assessment_template.title     = params_root[:title]
      @assessment_template.ownerable = ownerable

      controller_save_record(@assessment_template)
    end

    # ## Private
    private
    
    def permission_denied(message='Cannot access this resource.', options={})
      options[:user_message] = message
      raise_access_denied_exception(message, :create, nil, options)
    end
    
  end
end; end; end;
