module Totem; module Core; module Controllers; module ApiRender; module Message

  # Message option keys:
  #   message: message body
  #   from:    [string|record|records] (default current user) if string used as-is; if [record|records] will generate from records
  #   to:      [string|record|records] if string used as-is; if [record|records] will generate from records
  #   users:   [record|records] used to generate 'to'
  #   teams:   [record|records] used to generate 'to'
  #   any other key-value: added as-is to message json

  # Examples:
  #   controller_render_message(message: message) #=> from current_user, time now
  #   controller_render_message(message: message, users: users) #=> from current_user, time now, to users (array of user hashes)
  #   controller_render_message(message: message, from: user, to: users, teams: teams)    #=> from user, time now, to users & teams
  #   controller_render_message(message: message, from: user, users: users, teams: teams) #=> same as above

  def controller_render_message(options={}); controller_render_json(controller_message_json(options)); end

  def controller_message_json(options={})
    json = Hash.new
    options.each do |key, value|
      controller_message_add_to_json(json, key, value)
    end
    controller_message_add_custom_values_to_json(json, options)
    controller_message_finalize_json(json, options)
    controller_message_debug(json, options)  if options[:debug] == true
    json
  end

  private

  CONTROLLER_MESSAGE_TO_KEYS = [:to, :users, :teams]  # keys to add to the message[:to]

  def controller_message_finalize_json(json, options)
    json[:time]  ||= controller_message_time
    json[:from]  ||= controller_message_json_user(current_user)
  end

  def controller_message_add_custom_values_to_json(json, options)
    options_keys = options.symbolize_keys.except(:time, :from, :message, :debug, *CONTROLLER_MESSAGE_TO_KEYS).keys
    custom_keys  = (options_keys - json.keys)
    return if custom_keys.blank?
    custom_keys.each do |key|
      value     = options[key]
      json[key] = value  unless json.has_key?(key)
    end
  end

  # ###
  # ### Add Key Values to JSON.
  # ###

  def controller_message_add_to_json(json, key, value)
    case key.to_sym
    when :message                       then json[:message] = value
    when :time                          then json[:time]    = controller_message_time(value)
    when :from                          then controller_message_array_value(json, key, value)
    when *CONTROLLER_MESSAGE_TO_KEYS    then controller_message_array_value(json, :to, value)
    end
  end

  def controller_message_array_value(json, key, value)
    json[key] ||= Array.new
    msg_value   = controller_message_value(value)
    case
    when msg_value.blank?
    when msg_value.is_a?(String)   then json[key].push(value) 
    when msg_value.is_a?(Array)    then json[key].push(*msg_value)
    else
      # TODO: raise error
    end
  end

  def controller_message_value(value)
    return value if value.is_a?(String)
    return nil   if value.blank?
    array = Array.new
    Array.wrap(value).each do |value|
      array.push controller_message_active_record?(value) ? controller_message_record_json(value) : value
    end
    array
  end

  # ###
  # ### Record JSON.
  # ###

  def controller_message_record_json(record)
    type   = controller_message_record_type(record)
    method = 'controller_message_json_' + type.to_s
    # TODO: raise error if doesn't respond_to?(method)
    return {title: :bad} unless self.respond_to?(method, true)
    send(method, record)
  end

  def controller_message_record_type(record); record.blank? ? '' : record.class.name.demodulize.underscore.to_sym; end

  def controller_message_active_record?(value)
    return false if value.is_a?(Class)
    value.class.ancestors.include?(::ActiveRecord::Base) && value.respond_to?(:id)
  end

  # ###
  # ### Record-to-JSON (method per model class).
  # ###

  def controller_message_json_team(team)
    {id: team.id, title: team.title, type: :team}
  end

  def controller_message_json_user(user)
    {id: user.id, first_name: user.first_name, last_name: user.last_name, title: user.title, type: :user}
  end

  # ###
  # ### Time.
  # ###

  def controller_message_time(value=nil)
    return controller_message_time_now if value.blank?
    return value if value.is_a?(Time)
    return value if value.is_a?(String)
    controller_message_time_now
  end

  def controller_message_time_now; Time.now.utc; end

  # ###
  # ### Debug
  # ###

  def controller_message_debug(json, options)
    time     = json[:time]
    time_str = time.is_a?(Time) ? time.to_s(:db) : time.to_s
    puts "\n"
    controller_debug_message ('-' * 100)
    controller_debug_message "Controller: #{self.class.name}##{self.action_name}"
    controller_debug_message "Time      : #{time_str.inspect}"
    controller_debug_message "From      : #{json[:from].inspect}"
    controller_debug_message "To        : #{json[:to].inspect}"  if json[:to].present?
    controller_debug_message "Message   : #{json[:message].inspect}"
    controller_debug_message "#{('-' * 100)}\n\n"
  end

end; end; end; end; end
