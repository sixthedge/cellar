# Be sure to restart your server when you modify this file.
require 'singleton'
module Totem; module PubSub; class Connection
  include Singleton
  # Singleton class to connect to the pubsub server and hold a reference to the client.
  # Note: When in console mode and perform a 'reload!' will create another connection.  When exit the console, all console connections are removed.
  # Change the 'pub_sub.rb' initializer to establish the connection at initialization (see client documentation).

  extend ::Totem::Core::Support::Shared

  def self.client
    @pubsub_client ||= begin
      if defined? ::Redis
        url = ::Rails.application.secrets.dig(:pub_sub, 'url')
        if url.blank?
          warning "The pub_sub [url: #{url.inspect}] is blank.  PubSub is INACTIVE."
          return nil
        end
        begin
          id = 'totem'  # name of the redis connection e.g. client list #=> addr=...name=totem
          id += '-console' if defined?(::Rails::Console)
          rc = ::Redis.new(url: url, id: id)
          rc.ping
        rescue ::Redis::CannotConnectError
          warning "Redis connect failure for [host: #{rc.client.host.inspect}] [port: #{rc.client.port.inspect}]. Pubsub is INACTIVE."
          nil
        else
          info "Connected to Redis server [host: #{rc.client.host.inspect}] [port: #{rc.client.port.inspect}]."
          rc
        end
      else
        warning "Redis gem is not included. PubSub is INACTIVE."
        nil
      end
    end
  end

  class PubSubConnectionError < StandardError; end

end; end; end