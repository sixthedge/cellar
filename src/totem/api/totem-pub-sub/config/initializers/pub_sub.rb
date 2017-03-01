# ### Un-comment if want to establish the pubsub redis connection at initialization.
require 'totem/pub_sub/connection'
::Totem::PubSub::Connection.client
# ###

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include ::Totem::PubSub::Client
  end
end
