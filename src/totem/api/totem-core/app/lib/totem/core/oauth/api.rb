require 'rest_client'

# Wrapper class to handle S2S calls from a Totem Platform to Totem OAuth
# => This is only for trusted endpoints, as it will allow for account creation, etc.
# => params[:secret] is REQUIRED by ALL calls.

# TODO:
# The create_user should probably have an option to add the user to a certain Doorkeeper::Application. 


module Totem
  module Core
    module Oauth
      class Api

          attr_reader :providers
          attr_reader :provider
          attr_reader :options

          def initialize(providers, options={})
            @providers = providers
            @provider  = providers.first # In the future, may want to determine provider based on additional criteria instead of just order (e.g. response time).
            @options   = options
          end

          # => Create a Totem OAuth user account from a trusted platform.
          # POST request to /api/trusted/users
          # RETURN:
          #   => {"id"=>19, "first_name"=>"ApiTestFirst", "last_name"=>"ApiTestLast", "settings"=>{}, "email"=>"test@test.com", "authentication_token"=>nil, "created_at"=>"2014-11-04T21:04:21.807Z", "updated_at"=>"2014-11-04T21:04:21.807Z"}
          def create_user(params, options={})
            user = params.dig('data', 'attributes')
            [:first_name, :last_name, :password, :email].each do |k|
              raise InvalidParamsError, "Create user missing parameter #{k.inspect} in params #{params.inspect}." if user[k].blank?
            end
            email = user[:email]
            raise InvalidEmailError, "Create user email #{email.inspect} is invalid." unless is_valid_email?(email)
            post_request 'trusted/users', json_api_to_oauth_params('user', params)
          end

          # => Check if an email exists on the master Totem OAuth server.
          # GET request to /api/trusted/users/email_check
          # REQUIRED:
          #   => params[:email]
          # RETURN:
          #   => { email: email, valid: [true|false] }
          def email_check(params)
            raise InvalidEmailError, "Email check email is blank." if params[:email].blank?
            get_request 'trusted/users/email_check', params
          end

          def email_exists?(params); !response_valid?(email_check(params)); end

          # => Verify user's password.
          # GET request to /api/trusted/users/reset_password
          # REQUIRED:
          #   => params[:email]
          #   => params[:password]
          # RETURN:
          #   => { email: email, valid: [true|false] }
          def verify_password(params)
            email    = params[:email]
            password = params[:password]
            raise InvalidParamsError, "Verify password email is blank." if email.blank?
            raise InvalidParamsError, "Verify password password is blank for email #{email.inspect}." if password.blank?
            post_request 'trusted/users/password_check', email: email, password: password
          end

          def password_valid?(params); response_valid?(verify_password(params)); end

          def get_password_reset_token(params)
            email = params[:email]
            raise InvalidParamsError, "Reset password token get email is blank." if email.blank?
            get_request 'trusted/users/get_password_reset_token', email: email
          end

          def set_password_from_token(params)
            # { token: 'token-here', password: 'password-to-set' }
            token              = params[:token]
            email              = params[:email]
            password           = params[:password]
            raise InvalidParamsError, "Set password from token: token is blank." if token.blank?
            raise InvalidParamsError, "Set password from token: email is blank." if email.blank?
            raise InvalidParamsError, "Set password from token: password is blank." if password.blank?
            post_request 'trusted/users/set_password_from_token', token: token, email: email, password: password
          end

          private

          # ###
          # ### Send Oauth Request.
          # ###

          def get_request(api_endpoint, params)
            add_platform_to_params(params)
            url = api_url(api_endpoint)
            begin
              request = RestClient.get url, { params: params }
            rescue => e
              # In the future, if multiple oauth servers are supported, could check
              # the error for connection refused and try next provider if available.
              handle_error('get', url, e)
            end
            format_json_return(request)
          end

          def post_request(api_endpoint, params)
            add_platform_to_params(params)
            url = api_url(api_endpoint)
            begin
              request = RestClient.post url, params.to_json, content_type: :json
            rescue => e
              handle_error('post', url, e)
            end
            format_json_return(request)
          end

          # ###
          # ### Helpers
          # ###

          def api_url(api_endpoint)
            site         = provider.provider.site
            api_endpoint = '/' + api_endpoint  unless api_endpoint.start_with?('/')
            site + '/api' + api_endpoint
          end

          def add_platform_to_params(params)
            params[:secret]    = provider.platform.client_secret
            # params[:client_id] = provider.platform.client_id
          end

          def json_api_to_oauth_params(key, params)
            attributes = params.dig('data', 'attributes')
            {"#{key}": attributes}
          end

          def response_valid?(response); response['valid'] == true; end

          def is_valid_email?(email)
            return false if email.blank?
            (email || '').to_s.match /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          end

          def format_json_return(request)
            JSON.parse(request)
          end

          def handle_error(verb, url, e)
            message = e.message || 'unknown error'
            case
            when connection_refused?(e)
              raise ConnectionRefused, "#{verb} url: #{url.inspect} [error: #{message.inspect}]."
            else
              raise ConnectionError, "#{verb} url: #{url.inspect} [error: #{message.inspect}]."
            end
          end

          def connection_refused?(e)
            e.class == Errno::ECONNREFUSED
          end

      end
    end
  end
end
