module Thinkspace; module Common; module Api;
  class UploadsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # before_action :set_presigned_post, only: [:sign]

    # # API Proxy to S3
    def upload
      begin
        uploader = type_uploader.new(params, current_user, self)
        response = uploader.upload
        if response.is_a?(Hash)
          response['raw'] = true
          controller_render_json(response)
        else
          controller_render(response)
        end
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
      controller_render_no_content
    end

    private

    def type_uploader
      type = params[:uploader_type]
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