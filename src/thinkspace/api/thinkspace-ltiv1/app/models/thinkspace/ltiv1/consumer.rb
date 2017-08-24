module Thinkspace; module Ltiv1
  class Consumer < ActiveRecord::Base
    attr_encrypted :consumer_secret, key: Rails.application.secrets.lti['consumer_encryption_key']

    def generate_consumer_secret; self.consumer_secret = SecureRandom.base64; self.save; end

    totem_associations
  end
end; end