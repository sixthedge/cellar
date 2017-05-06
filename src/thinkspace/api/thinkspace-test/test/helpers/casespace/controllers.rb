module Test::Casespace::Controllers
  extend ActiveSupport::Concern
  included do

    def get_controller_model_class_name; @controller.controller_model_class_name; end

    def is_controller_model?(class_name); get_controller_model_class_name == class_name; end

    def new_params_hash; HashWithIndifferentAccess.new; end

    # Send action requests.
    def get_params_with_auth(options)
      auth   = get_auth_params(options)
      params = options[:params] || Hash.new
      if auth.present?
        params[:auth] = (params[:auth] || Hash.new).reverse_merge(auth)
      end
      params
    end

    def get_auth_params(options)
      auth = Hash.new
      (options[:auth] || Hash.new).each do |key, value|
        case
        when key == :authable && value.present?
          auth[:authable_type] = value.class.name.underscore
          auth[:authable_id]   = value.id
        when key == :ownerable && value.present?
          auth[:ownerable_type] = value.class.name.underscore
          auth[:ownerable_id]   = value.id
        when key == :view
          auth[:view_type] = value.class.name.underscore
          auth[:view_ids]  = [options[:view_ids] || value.id].flatten.compact
        when value.present? && !value.respond_to?(:ancestors)
          auth[key] = value
        end
      end
      auth
    end

    def controller_collection(*args)
      options  = args.extract_options!
      username = args.shift
      action   = options[:action] || :index
      options[:params] = (options[:params] || Hash.new)
      options[:params] = get_params_with_auth(options)
      username = get_username(username)
      controller_json_for(action, username, options)
    end

    def controller_member(*args)
      options  = args.extract_options!
      username = args.shift
      id       = options[:id]
      username = get_username(username)
      raise "Id is required for controller member action for user #{username.inspect}.\nOptions: #{options.inspect}"  if id.blank?
      action           = options[:action] || :show
      options[:params] = (options[:params] || Hash.new).merge(id: id)
      options[:params] = get_params_with_auth(options)
      controller_json_for(action, username, options)
    end

    def controller_json_for(action, username, options={})
      verb = options[:verb] || controller_action_verb(action)
      raise "Blank request verb for action #{action.inspect}"  if verb.blank?
      request_for(verb, action, username, options)
    end

    def controller_action_verb(action)
      case action.to_sym
      when :create  then :post
      when :show    then :get
      when :update  then :put
      when :destroy then :delete
      else
        :get
      end
    end

    def request_for(verb, action, username, options={})
      verb        = verb.to_s.upcase
      user        = get_user(username)
      auth_token  = sign_in_user(user)
      params      = options[:params]  || {}
      auth_header = 'Token token="' + auth_token + '", email="' + user.email + '"'
      # save request params for failures
      auth      = options[:auth] || Hash.new
      authable  = auth[:authable]
      ownerable = auth[:ownerable]
      rp        = @_request_params = Array.new
      rp.push "\n"
      rp.push "---params: #{@NAME.inspect} " + ('-' * 40)
      rp.push "action   = #{action.inspect}"
      rp.push "auth hdr = #{auth_header}"
      rp.push "verb     = #{verb.inspect}"
      rp.push "user id  = #{get_user(username).id}"
      rp.push "username = #{username.inspect}  (sign_in_user)"
      rp.push "authable = #{authable.title}"   if authable.present?
      rp.push "ownerable= #{ownerable.title}"  if ownerable.present?
      rp.push 'params   ='
      rp.push params.inspect
      rp.push ''
      puts(printable_request_params) if options[:print_params].present?
      @request.headers['Authorization'] = auth_header
      process_request(action, verb, params)
    end

    def printable_request_params; @_request_params.join("\n"); end

    # Authorization Token token="VKnVFLXifwsjXRdLBy81", user_email="read_1@sixthedge.com"
    def sign_in_user(user)
      api_session = ::Totem::Settings.authentication.current_model_class(user, :api_session_model)
      auth_token = '123456789_' + user.id.to_s
      api_session.create(user_id: user.id, authentication_token: auth_token)
      auth_token
    end

    def process_request(action, verb, params)
      process(action, method: verb, params: params)
      response_json(@response)
    end

    def response_json(response)
      body = response.body
      return nil if body.blank?
      HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(body))
    end

  end # included
end
