module Thinkspace
  module Common
    module BaseMailer
      extend ActiveSupport::Concern

      def format_subject(suffix)
        '[ThinkSpace] ' + suffix
      end

    end
  end
end