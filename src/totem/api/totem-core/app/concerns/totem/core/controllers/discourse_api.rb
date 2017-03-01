require 'open-uri'

module Totem
  module Core
    module Controllers
      module DiscourseApi

        def support
          category = get_category_type_title('support')
          title    = get_title
          raw      = get_raw
          begin
            topic = @client.create_topic(
              category:         category,
              auto_track:       false,
              title:            title,
              skip_validations: true,
              raw:              raw
            )
            render_discourse_success get_category_type_success_message('support')
          rescue => e
            render_discourse_errors(e.message)
          end
        end

        private

        def get_discourse_username
          external_id = current_user.oauth_user_id
          url         = "#{@host}/users/by-external/#{external_id}.json"
          open(url) do |json|
            response = JSON.parse(json.read)
            username = response['user']['username']
            return username
          end
        end

        def set_api_credentials
          @host     = Rails.application.secrets.discourse['host']
          @key      = Rails.application.secrets.discourse['key']
          # in development, use thinkbot instead of using development oauth ids to get the username
          @username = Rails.env.production? ? get_discourse_username : Rails.application.secrets.discourse['username']
        end

        def set_api_client
          @client              = ::DiscourseApi::Client.new(@host)
          @client.api_key      = @key
          @client.api_username = @username
          @client.ssl(verify: false) if Rails.env.development?
        end

        def get_category_type_secrets(type)
          Rails.application.secrets.discourse['categories'][type]
        end

        def get_category_type_title(type)
          get_category_type_secrets(type)['title']
        end

        def get_category_type_success_message(type)
          secrets = get_category_type_secrets(type)
          return '' unless secrets.has_key?('messages')
          return '' unless secrets['messages'].has_key?('success')
          secrets['messages']['success']
        end

        def get_title
          params_title = params[:title] || 'No title given.'
          time_string  = Time.now.strftime('%D %r %Z')
          "[#{current_user.full_name}] - #{params_title} - [#{time_string}]"
        end

        def get_raw
          params_raw   = params[:raw] || 'No raw message added.'
          params_title = params[:title] || 'No title given.'
          metadata     = params[:metadata] || {}
          raw          = ''
          raw         += "## Ticket for #{current_user.full_name}\n"
          raw         += "### User\n"
          raw         += "* name: #{current_user.full_name}\n"
          raw         += "* email: #{current_user.email}\n"
          raw         += "### Details\n"
          raw         += "* title: #{params_title}\n"
          raw         += "* message: #{params_raw}\n"
          raw         += "### Metadata\n"
          metadata.each do |key, value|
            raw += "* #{key}: #{value}\n"
          end
          raw
        end

        def render_discourse_success(message=nil)
          options          = {}
          options[:status] = 200
          options[:json]   = {message: message}
          render options
        end

        def render_discourse_errors(message)
          json_message     = message.gsub('=>', ':')
          errors_json      = JSON.parse(json_message)
          errors           = errors_json['errors'] || ['There has been an error, please try again.']
          options          = {}
          options[:status] = 422
          options[:json]   = {errors: errors}
          render options
        end


      end
    end
  end
end