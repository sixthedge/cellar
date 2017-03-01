module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module Messages

  def publish_messages_to_users
    publish_messages({users: all_params_users}, assignment)
  end

  def publish_messages(options={}, authable=phase)
    return unless (message? || admin_message?)
    time       = pubsub_time
    pusers     = options[:users] || []
    pteams     = options[:teams] || []
    ownerables = pusers + pteams
    if message?
      value = pubsub_message_value(message: message, time: time)
      publish_message(ownerables, value, authable)
    end
    if message? || admin_message?
      value = pubsub_message_value(message: admin_message || message, time: time, users: pusers, teams: pteams)
      publish_admin_message(value, authable)
    end
  end

  def publish_message(ownerables, value, authable=phase)
    rooms = assignment_ownerable_rooms(ownerables)
    server_event_record_class.new
      .on_error(error_class)
      .origin(self)
      .authable(authable)
      .user(current_user)
      .rooms(rooms)
      .event(:message)
      .value(value)
      .publish
  end

  def publish_admin_message(value, authable=phase)
    room = assignment_admin_room
    server_event_record_class.new
      .on_error(error_class)
      .origin(self)
      .authable(authable)
      .user(current_user)
      .rooms(room)
      .event(:message)
      .value(value)
      .publish
  end

  def pubsub_message_value(options); controller_message_json(options); end

  def pubsub_time; controller_message_time_now; end

end; end; end; end; end; end
