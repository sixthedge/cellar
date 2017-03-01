# Be sure to restart your server when you modify this file. 'totem_pubsub' (the PubSub instance) is create on the class.
module Totem; module PubSub; class Publish

  # An instance of this class is referenced by the class method 'totem_pubsub' when the PubSub::Client is included.
  # An object (e.g. controller) should call 'pubsub.data' to return a new PubSub::Data instance that can be modified.
  # Do not modify any of these Publish variables directly.
  def initialize(platform_name, pubsub_client, options={})
    @platform_name = platform_name
    @client        = pubsub_client
    @debugging     = (options[:debug] == true)
    raise PublishError, "PubSub server is blank."  if @client.blank?
  end

  def data(init_value={}); PubSub::Data.new(self, init_value); end

  def publish(pubsub_data)
    data         = pubsub_data.get_data
    channel      = pubsub_data.get_channel || channel_name
    encoded_data = ::ActiveSupport::JSON.encode(data)
    if debug?
      debug '-' * 100
      debug "#{self.class.name}:"
      debug "  Channel   : #{channel.inspect}"
      debug "  Action    : #{data[:action]}"
      debug "  Room Event: #{data[:room_event]}"
      debug "  Room Type : #{data[:room_type]}"
      debug "  Data: #{data.inspect}"
      # debug "  Encoded: #{encoded_data.inspect}"
      debug '-' * 100
    end
    @client.publish channel, encoded_data
  end

  def publish_raw(channel, data)
    encoded_data = ::ActiveSupport::JSON.encode(data)
    @client.publish channel, encoded_data
  end

  def channel_name; "/#{@platform_name}"; end

  def room_with_ownerable(record_or_scope, ownerable, *args)
    ownerable_key = record_or_scope_key(ownerable)
    room_for(record_or_scope, ownerable_key, *args)
  end

  def room_for(record_or_scope, *args)
    room = record_or_scope_key(record_or_scope)
    args.blank? ? room : room + '/' + args.join('/')
  end

  def room_members?(room); room_count(room) > 0; end

  def room_count(room)
    return 0 if room.blank?
    count = @client.hget(key_for_room_counts, room)
    return 0 if count.blank? || !count.is_a?(String)
    return 0 unless count.match(/^\d+$/)
    count.to_i
  end

  def record_or_scope_key(record_or_scope)
    if scope?(record_or_scope)
      key = record_or_scope.model.name.underscore.pluralize
    else
      klass = (record_or_scope.is_a?(Class) ? record_or_scope : record_or_scope.class)
      key   = (klass.name || 'unknown').underscore
      key  += "/#{record_or_scope.id}"  if record_or_scope.respond_to?(:id)
    end
    key
  end

  def key_for_room_counts; @_redis_room_counts_key ||= "#{channel_name}/room_counts"; end

  def scope?(record_or_scope); record_or_scope.is_a?(::ActiveRecord::Relation); end

  def debug?; @debugging == true; end

  def debug(message)
    puts "[debug] #{message}"  if ::Rails.env.test?
    ::Rails.logger.debug '[debug] ' + message
  end

  class PublishError < StandardError; end

end; end; end
