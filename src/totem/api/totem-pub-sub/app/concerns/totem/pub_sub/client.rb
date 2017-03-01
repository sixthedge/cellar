# Be sure to restart your server when you modify this file.
module Totem; module PubSub; module Client

  # Add Totem's PubSub to an object.
  #
  # This module can be included in any object (e.g. controller, model, etc.) that is valid
  # for Totem::Settings.engine.current_platform_name(self).
  # It is already included in controllers via the 'pub_sub.rb' initializer (the typically usage).
  # A 'totem_pubsub' class method is added plus a 'pubsub' instance method.
  #
  # The PubSub::Connection will be established by the class method 'totem_pubsub' or it will be established on
  # the first use of the instance method 'pubsub' (adding 'totem_pubsub' ensures a connection can be made at load time).
  # An alternative is to change the 'pub_sub.rb' initializer to establish the connection.
  #
  # The object (e.g. controller) should call 'pubsub.data' to return a new PubSub::Data instance that can be populated.
  #
  # Example (for a model):
  #   class User < ActiveRecord::Base
  #     include ::Totem::PubSub::Client
  #     totem_pubsub  # establish the connection if not already established (optional)
  #     def publish_something
  #       data  = {first_name: self.first_name, last_name: self.last_name}
  #       rooms = ['roomA', 'roomB']
  #       pubsub.data(data).rooms(rooms).publish
  #     end

  extend ::ActiveSupport::Concern

  # Define the 'totem_pubsub' class method (only class method added to the including class).
  class_methods do
    def totem_pubsub(*args)
      @totem_pubsub ||= begin
        options       = args.extract_options!
        platform_name = ::Totem::Settings.engine.current_platform_name(self)
        pubsub_client = ::Totem::PubSub::Connection.client || MockClient.new
        PubSub::Publish.new(platform_name, pubsub_client, options)
      end
    end
  end

  # Convience instance method that references the 'totem_pubsub' class method (e.g. pubsub.data).
  included do
    def pubsub; self.class.totem_pubsub; end
  end

  class MockClient
    private
    include ::Totem::Core::Support::Shared
    def method_missing(method, *args); mock_message(method, *args); end
    def mock_message(method, *args)
      warning "PubSub #{method.to_s.inspect} request was made but PubSub is INACTIVE.  Ensure Redis is available and the Redis host/port have been provided."
      warning "PubSub #{method.to_s.inspect} ARGS=#{args}"
      nil
    end
  end

end; end; end
