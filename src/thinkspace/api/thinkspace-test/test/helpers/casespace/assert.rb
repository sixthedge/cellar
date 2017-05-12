module Test::Casespace::Assert
  extend ActiveSupport::Concern
  included do

    # Assert Failure Message.
    def afm(proc=nil)
      Proc.new do
        msg     = proc.present? ? Proc.new {proc} : nil
        message = (msg && msg.call) || ''
        get_let_value(:print_params_on_failure) ? (message + "\n" + printable_request_params) : message
      end
    end

    def assert_can(*args)
      username = args.shift
      subject  = args.shift
      ability  = get_ability(username)
      name     = get_username(username)
      [args].flatten.each do |action|
        assert_equal true, ability.can?(action, subject), "#{name.inspect} can #{action.to_s.inspect} #{get_ability_subject_name(subject).inspect}"
      end
    end

    def assert_cannot(*args)
      username = args.shift
      subject  = args.shift
      ability  = get_ability(username)
      name     = get_username(username)
      [args].flatten.each do |action|
        assert_equal true, ability.cannot?(action, subject), "#{name.inspect} cannot #{action.to_s.inspect} #{get_ability_subject_name(subject).inspect}"
      end
    end

    def assert_no_user_id_keys(hash)
      keys = hash.keys.select {|k| k.match('user_id')}
      assert_equal [], keys, 'does not contain user_id keys'
    end

    def assert_no_ownerable_key(hash)
      keys = hash.keys.select {|k| k == 'ownerable'}
      assert_equal [], keys, 'does not contain ownerable association key'
    end

    def assert_route_authorized(route, hash);   assert_authorized(hash); end
    def assert_route_unauthorized(route, hash); assert_unauthorized(hash, route.unauthorized_messages); end

    def assert_unauthorized(hash, error_messages)
      assert_equal true, hash.present?, 'unauthorized response is present'
      assert_equal ['errors'], hash.keys, afm('==> authorized -> expected to be unauthorized')
      error_hash = hash['errors']
      assert_kind_of Hash, error_hash, 'unauthorized response "errors" is an hash'
      message = error_hash['message']
      assert_error_message_match(message, /not authorized/i, error_messages)
      error_statuses = [422, 423]
      assert_equal true,  error_statuses.include?(@response.status), "#{@response.status} response status should be in #{error_statuses}"
      debug_hash = error_hash['debug']   || Hash.new
      message    = debug_hash['message'] || ''
      assert_error_message_match(message, error_messages)  if message.present?
    end

    def assert_authorized(hash)
      (assert_for_count && return) if hash.nil?  # will be nil on destroy, sign_out, etc.
      assert_kind_of Hash, hash, 'authorized response is not a hash'
      assert_nil hash['errors'], afm('==> unauthorized -> expected to be authorized')
      refute_equal 423, @response.status, 'response status should not be 423'
    end

    def assert_for_count; assert(true, true); end  # assertion was perform via code but show it was done

    # Call using the method method(:method-name).  e.g. assert_sign_in method(:send_route_request)
    def assert_sign_in(method); assert_raise_error(method, oauth_errors, /connection refused/i); end

    def assert_route_error(method, route); assert_raise_error(method, route.error_classes, route.error_messages); end

    def assert_raise_error(method, error_classes=nil, error_messages=nil)
      if error_classes.blank?
        assert_raise_any_exception(method, error_messages)
      else
        e = assert_raise(*error_classes) {method.call}
        assert_error_message_match(e.to_s, error_messages)
      end
    end

    def assert_raise_any_exception(method, error_messages=nil)
      begin
        method.call
      rescue => e
        assert_kind_of Exception, e, 'is not an exception'
        assert_error_message_match(e.to_s, error_messages)
      end
    end

    def assert_error_message_match(message, *args)
      if error_message_match?(message, args)
        assert_for_count
      else
        assert_equal true, false, "--expected the error message: #{message}\n--to match one of #{args}"
      end
      true # return true so can do  assert_sign_in... && return
    end

    def error_message_match?(message, *args)
      error_messages = [args].flatten.compact
      return true if message.blank? || error_messages.blank?
      found_match = false
      error_messages.each do |match|
        regex = match.is_a?(Regexp) ? match : Regexp.new(/#{match}/i)
        if message.match(regex)
          found_match = true
          break
        end
      end
      found_match
    end

    # ###
    # ### Assert Exceptions. e.g. e = assert_raise(*oauth_errors) {send_route_request}
    # ###

    def runtime_error; ::RuntimeError; end

    def record_not_found_error; ::ActiveRecord::RecordNotFound; end

    def oauth_errors
      [::Totem::Core::Oauth::ConnectionRefused]
    end

  end # included
end
