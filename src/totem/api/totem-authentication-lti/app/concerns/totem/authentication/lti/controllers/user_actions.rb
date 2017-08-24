module Totem
  module Authentication
    module Lti
      module Controllers
        module UserActions

          def sign_in
            @handler = handler_class.new(params, request)

            begin
              @handler.process
            rescue @handler.request_validation_error, @handler.consumer_not_found_error
              return redirect_on_validation_error
            rescue @handler.resource_not_found_error
              return redirect_on_resource_not_found_error
            end

            redirect_on_success
          end


          private


          def redirect_on_validation_error
            redirect_to_lti_sign_in_failure
          end

          def redirect_on_resource_not_found_error
            if @handler.is_instructor?
              @session = find_or_create_api_session(@handler.user)
              redirect_to_lti_setup
            else
              redirect_to_lti_nag
            end
          end

          def redirect_on_success
            @session = find_or_create_api_session(@handler.user)
            redirect_to_lti_sign_in_success
          end

          def handler_class; Totem::Authentication::Lti::RequestHandler; end

          def get_lti_sign_in_failure_query_params
            {
              email: @handler.email,
              error: true
            }
          end

          def get_lti_nag_query_params
            {
              email: @handler.email
            }
          end

          def get_lti_sign_in_success_query_params
            {
              user_id:      @handler.user.id,
              email:        @handler.email,
              context_type: @handler.resource.contextable_type.underscore.split('/').pop,
              context_id:   @handler.resource.contextable_id,
              auth_token:   @session.authentication_token
            }
          end

          def get_lti_setup_query_params
            {
              email:               @handler.email,
              context_title:       @handler.context_title,
              resource_link_id:    @handler.resource_link_id,
              resource_link_title: @handler.resource_link_title,
              consumer_title:      @handler.consumer.title,
              user_id:             @handler.user.id,
              auth_token:          @session.authentication_token
            }
          end

          def add_query_params_to_url(params)
            return @url unless params.present?
            @url = @url + '?'
            params.each do |key, value|
              @url = @url + key.to_s + '=' + value.to_s + '&'
            end
            @url.chop!
          end

          def redirect_to_lti_sign_in_success
            qp   = get_lti_sign_in_success_query_params
            @url = lti_sign_in_url
            add_query_params_to_url(qp)
            redirect_to @url
          end

          def redirect_to_lti_sign_in_failure
            qp   = get_lti_sign_in_failure_query_params
            @url = lti_sign_in_url
            add_query_params_to_url(qp)
            redirect_to @url
          end

          def redirect_to_lti_setup
            qp   = get_lti_setup_query_params
            @url = lti_setup_url
            add_query_params_to_url(qp)
            redirect_to @url
          end

          def redirect_to_lti_nag
            qp   = get_lti_nag_query_params
            @url = lti_nag_url
            add_query_params_to_url(qp)
            redirect_to @url
          end

          def lti_sign_in_url; app_domain + '/lti/sign_in'; end
          def lti_setup_url;   app_domain + '/lti/setup';   end
          def lti_nag_url;     app_domain + '/lti/error';   end

          def app_domain; Rails.application.secrets.smtp['postmark']['domain']; end

        end
      end
    end
  end
end
