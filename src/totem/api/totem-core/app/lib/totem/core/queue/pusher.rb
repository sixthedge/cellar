module Totem
  module Core
    module Queue
      class Pusher

        def initialize(message, handler, source_id = nil, options = {})
          raise InvalidArguments, "No message or handler passed in for SQS [#{message}], [#{handler}]." unless message and handler
          @message              = message
          @message['handler']   = handler
          @message['source_id'] = source_id if source_id
          @options              = options
          set_queue
        end

        def set_queue
          sqs    = AWS::SQS.new(access_key_id: Rails.application.secrets.aws['sqs']['access_key'], secret_access_key: Rails.application.secrets.aws['sqs']['secret_access_key'])
          @queue = sqs.queues.named(Rails.application.secrets.aws['sqs']['queue_name'])
          raise InvalidQueue, "Invalid queue specified to push to." unless @queue
        end

        def process
          message = @message.to_json
          @queue.send_message(message)
        end
        
      end

      class InvalidQueue     < StandardError; end
      class InvalidArguments < StandardError; end
    end
  end
end