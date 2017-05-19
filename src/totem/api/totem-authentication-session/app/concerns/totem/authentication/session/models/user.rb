module Totem
  module Authentication
    module Session
      module Models
        module User

          extend ActiveSupport::Concern

          # Fully qualified exceptions since may be mixed into another engine's user model.

          module ClassMethods

            # Class method to find or create an user instance.
            # Some possible additions to this method:
            #  * populate user columns based on an options :column_names array
            def find_or_create_for_oauth_user(oauth_data)
              validate_required_oauth_columns
              oauth_user_id = oauth_data.uid
              raise Totem::Authentication::Session::MissingSessionUserId, "Blank oauth user id in oauth data. #{oauth_data.inspect}"    if oauth_user_id.blank?
              user = self.find_by(oauth_user_id: oauth_user_id)
              user = find_using_oauth_options_strategy(oauth_data, oauth_user_id) if user.blank?
              if user.blank?
                user               = self.new
                user.oauth_user_id = oauth_user_id
              end
              # Anything in the info hash (currently email, first_name, last_name) get sent to user if they respond to the method.
              oauth_data.info.each do |attribute, value|
                method = "#{attribute}=".to_sym
                user.send method, value if user.respond_to?(method)
              end
              user
            end

            def find_using_oauth_options_strategy(oauth_data, oauth_user_id)
              options = (self.respond_to?(:user_oauth_options) && user_oauth_options) || {}
              raise Totem::Authentication::Session::InvalidUserOptions, "User oauth options must be a hash."  unless options.kind_of?(Hash)
              case
              when options[:update_oauth_user_id_on_email_match].present?
                find_using_oauth_email(oauth_data, oauth_user_id)
              else
                nil
              end
            end

            # If the platform allows creating users in its local user table, this
            # will update the existing record matching the email value if
            # the oauth_user_id is blank.
            def find_using_oauth_email(oauth_data, oauth_user_id)
              user = nil
              oauth_email = oauth_data.info.email
              if oauth_email.present?
                user = self.find_by(email: oauth_email)
                if user.present? && user.oauth_user_id.blank?
                  user.oauth_user_id = oauth_user_id
                else
                  user = nil  # don't update if has an oauth user id (will error on duplicate email validation)
                end
              end
              user
            end

            def validate_required_oauth_columns
              unless self.column_names.include?('oauth_user_id')
                raise Totem::Authentication::Session::MissingRequiredSessionColumn, "Missing [oauth_user_id] column in model #{self.name}."
              end
              unless self.column_names.include?('oauth_access_token')
                raise Totem::Authentication::Session::MissingRequiredSessionColumn, "Missing [oauth_access_token] column in model #{self.name}."
              end
            end

          end

          # ### Instance method to add the oauth access token to the record.
          # Also calls the instance method 'populate_oauth_columns' if it exists in the user model.
          def update_oauth_user_credentials(oauth_data)
            oauth_access_token = oauth_data.credentials.token
            raise Totem::Authentication::Session::MissingSessionUserAccessToken, "Blank oauth access token in oauth data. #{oauth_data.inspect}"    if oauth_access_token.blank?
            self.oauth_access_token = oauth_data.credentials.token
            if self.respond_to?(:populate_user_oauth_extra_info)
              extra_values = oauth_data.extra.user_info || {}
              self.populate_user_oauth_extra_info(extra_values)
            end
          end

          def sync_user_from_oauth_data(oauth_data)
            # oauth_data = { email: email, id: id, first_name: 'first', last_name: 'last', valid: true }
            oauth_data.each do |attribute, value|
              if attribute == 'id'
                self.oauth_user_id = value
              else
                method = "#{attribute}=".to_sym
                self.send method, value if self.respond_to?(method)
              end
            end
            self.save
            self
          end

        end
      end
    end
  end
end