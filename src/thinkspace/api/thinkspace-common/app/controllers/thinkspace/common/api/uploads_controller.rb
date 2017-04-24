module Thinkspace; module Common; module Api;
  class UploadsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # # API Proxy to S3
    def upload
      begin
        uploader = type_uploader.new(params, current_user, self)
        render_response(uploader.upload)
      rescue Thinkspace::Common::Uploaders::Exceptions::UploaderError => e
        permission_denied(e)
      end
    end

    # # Direct to S3 POST
    def sign
      begin
        uploader = type_uploader.new(params, current_user, self)
        uploader.authorize!
        controller_render_json(uploader.sign)
      rescue Thinkspace::Common::Uploaders::Exceptions::UploaderError => e
        permission_denied(e)
      end
    end

    def confirm
      begin
        uploader = type_uploader.new(params, current_user, self)
        uploader.authorize!
        render_response(uploader.confirm)
      rescue Thinkspace::Common::Uploaders::Exceptions::UploaderError => e
        permission_denied(e)
      end
    end

    private

    def render_response(response)
      if response.is_a?(Hash)
        response['raw'] = true
        controller_render_json(response)
      else
        controller_render(response)
      end
    end

    def params_uploader; @params_uploader ||= JSON.parse(params[:uploader] || '{}').with_indifferent_access; end 

    def type_uploader
      type = params_uploader[:type]
      permission_denied('Params did not contain :uploader_type') unless type.present?
      type  = type.split('/')
      index = type.length - 1 # One from the end
      type.insert(index, 'uploaders')
      type  = type.join('/')
      klass = type.classify.safe_constantize
      permission_denied("Type [#{type}] does not have a valid class.") unless klass.present?
      klass
    end

    def permission_denied(message='Cannot access this resource.', options={})
      action = options[:action] ||= :unknown
      options[:user_message] = message
      raise_access_denied_exception(message, action, nil, options)
    end

  end
end; end; end