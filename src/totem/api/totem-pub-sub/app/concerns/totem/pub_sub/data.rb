module Totem; module PubSub; class Data

  # PubSub data methods to standardize the message structure.
  # Some methods return 'self' so methods can be chained (e.g. pubsub.room(:abc).set(:mykey, :myvalue).publish).

  attr_reader :pubsub, :data

  def initialize(pubsub, data)
    @pubsub     = pubsub
    @data       = data || Hash.new
    @rooms      = Array.new
    @room_event = nil
    @timer      = nil
    @value      = nil
    @channel    = nil
    @namespace  = nil
    raise DataError, "PubSub data must be a hash not #{data.class.name.inspect} [#{data.inspect}]"  unless data.is_a?(Hash)
  end

  # Update the data based on the methods called and the values supplied.
  def get_data
    data.merge!(nsp: @namespace)          if @namespace.present?
    data.merge!(rooms: @rooms.uniq)       if @rooms.present?
    data.merge!(room_event: @room_event)  if @room_event.present?
    data.merge!(timer: @timer)            if @timer.present?
    data.merge!(value: @value)            if @value.present?
    data
  end

  def get_channel; @channel; end

  # Convience method to call the Publish instance's 'publish' method so can be the final method in a chain.
  def publish; pubsub.publish(self); end

  # ###
  # ### Chainable Methods (some methods have aliases).
  # ###
  # ### 'timer' and 'rooms|to|in' auto-set the action value (can be overriden by calling action(act) last).

  def action(act); data[:action] = act if act.present?; self; end

  def timer(val, act=:timer); action(act) if val.present? && val.is_a?(Hash); @timer = val; self; end

  def room(r)
    return self if r.blank?
    action(:rooms)
    r.is_a?(Array) ? @rooms += r : @rooms.push(r)
    self
  end
  alias :to :room
  alias :in :room

  def set(key, val); data[key] = val; self; end # Generic 'set' method to add any key/value.

  def value(val); @value = val; self; end

  def room_event(event); @room_event = event; self; end

  def message(msg); data[:message] = msg; self; end

  def namespace(ns); @namespace = ns; self; end
  alias :of :namespace

  def room_for(rs, *args); room pubsub.room_for(rs, *args); self; end

  def channel(name); @channel = name; self end

  class DataError < StandardError; end

end; end; end
