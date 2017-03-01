module Thinkspace
  module Common
    module Api
      module Admin
        class SpacesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          include Thinkspace::Common::SmarterCSV
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options

          def update
            @space.title = params_root[:title]
            controller_save_record(@space)
          end

          def create
            # Must do this to regenerate ability due to space_ids not having the new record.
            # => Without this, update on the record will return as false.
            @current_ability                     = nil 
            @space.title                         = params_root[:title]
            @space.thinkspace_common_space_types = [get_space_type]
            @space.state                         = 'active'
            @space.save ? add_user_to_space_as_owner_and_render : controller_render_error(@space)
          end

          def invite
            email = params[:email].strip.downcase
            role  = params[:role]
            @user = user_class.find_by(email: email)

            if @user.present?
              @user.refresh_activation unless @user.is_activated?
              @space_user = space_user_class.find_by(user_id: @user.id, space_id: @space.id)
              if @space_user.present?
                permission_denied("#{email} is already on the roster.")
              else
                @space_user = space_user_class.create(user_id: @user.id, space_id: @space.id, role: role)
                @space_user.activate!
                if @user.active? then @space_user.notify_added_to_space(current_user) else @space_user.notify_invited_to_space(current_user) end
                controller_render_json(get_invite_json)
              end
              
            else
              @user = user_class.new(email: email)
              if @user.save
                @space_user = space_user_class.create(user_id: @user.id, space_id: @space.id, role: role)
                @space_user.activate!
                @space_user.notify_invited_to_space(current_user)
                controller_render_json(get_invite_json)
              else
                message = @user.errors.messages[:email].first
                permission_denied(message)
              end
            end
          end

          def import
            attachments = params[:files]

            files              = []
            generated_model    = user_class.name
            settings           = {}
            settings[:headers] = { single: 'email' }
            settings[:save]    = false

            begin
              attachments.each do |attachment|
                file = file_class.new(generated_model: generated_model, settings: settings, attachment: attachment)
                file.save!
                files << file
              end

              files = process_roster_files(files)
              @space.delay.mass_invite(files, current_user)
              controller_render_json({})
            rescue => e
              permission_denied(get_message_for_import_error(e))
            end
            
          end

          def clone
            cloned_space = @space.cyclone_with_notification(current_user) # DelayedJob
            controller_render(@space)
          end

          def roster
            controller_render(@space)
          end

          def invitations
            controller_render(@space)
          end

          def teams
            # TODO: Take into account team_set_id?
            controller_render(@space)
          end

          def team_sets
            controller_render(@space)
          end

          private

          def add_user_to_space_as_owner_and_render
            @space.add_user_as_owner(current_user)
            controller_render(@space)
          end

          def get_space_type; space_type_class.find_by(title: 'Casespace'); end

          def invitation_class; Thinkspace::Common::Invitation; end
          def user_class;       Thinkspace::Common::User;       end
          def space_class;      Thinkspace::Common::Space;      end
          def space_user_class; Thinkspace::Common::SpaceUser;  end
          def space_type_class; Thinkspace::Common::SpaceType;  end
          def file_class;       Thinkspace::Importer::File;     end

          def process_roster_files(files)
            file_data = []
            files.each do |file|
              data = open(file.attachment.url)
              data, errors = convert_to_single_column(data, match: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
              file_data << {file: file, data: data, errors: errors}
            end
            file_data
          end

          def get_invite_json
            # TODO: totem method to slash class names?
            hash                                  = controller_as_json(@user)
            hash['thinkspace/common/users']       = [hash.delete('thinkspace/common/user')]
            hash['thinkspace/common/space_users'] = [@space_user]
            hash
          end

          def get_message_for_import_error(e=nil)
            return 'The provided file is not an accepted file type. Please submit a .csv file.' if e.is_a? invalid_record_error
            return 'The provided file has too few rows. Add more rows or invite users individually.' if e.is_a? not_enough_rows_error
            return 'The provided file has a row with no email. All rows must contain a valid email.' if e.is_a? unmatched_row_error
            return 'The provided file has a row with more than one email. All rows must contain only one email.' if e.is_a? overmatched_row_error
            return 'There was a problem processing the file. Please try again or contact support.'
          end

          def permission_denied(message='Cannot access this resource.', options={})
            action = options[:action] ||= :unknown
            options[:user_message] = options[:user_message] || message
            raise_access_denied_exception(message, action, nil, options)
          end

          def invalid_record_error;  ActiveRecord::RecordInvalid; end
          def not_enough_rows_error; Thinkspace::Common::SmarterCSV::InsufficientNumberOfRowsError; end
          def unmatched_row_error;   Thinkspace::Common::SmarterCSV::UnmatchedRowError; end
          def overmatched_row_error; Thinkspace::Common::SmarterCSV::OvermatchedRowError; end
        end
      end
    end
  end
end
