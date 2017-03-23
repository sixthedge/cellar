module Thinkspace; module Importer; module Uploaders;
  class Roster < Thinkspace::Common::Uploaders::Base
    include Thinkspace::Common::SmarterCSV

    # # Authorization
    def authorize!
      raise_authorization_error("Cannot update Space [#{authable.id}]") unless current_ability.can?(:update, authable)
    end

    # # Processing
    def upload
      begin
        response = []
        files.each do |file|
          f = new_file
          response.push(f) if f.save!
        end
        process_roster(response)
        render_success
      rescue => e
        raise_authorization_error("File could not be saved with: [#{e}].")
      end
    end

    # # File
    def new_file(**args)
      args ||= {}
      args = file_args.merge(attachment: file).merge(args)
      file_class.new(args)
    end

    def file_args; { importable: authable, generated_model: file_generated_model, settings: file_settings }; end
    def file_settings; { headers: { single: 'email'}, save: false }; end
    def file_generated_model; user_class.name; end

    # # Roster
    def process_roster(files)
      files     = Array.wrap(files)
      processed = []
      files.each do |file|
        storage_is_filesystem? ? data = ::File.open(Rails.root.join(file.attachment.path)) : data = open(file.attachment.url)
        data, errors = convert_to_single_column(data, match: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        processed.push({ file: file, data: data, errors: errors })
      end
      authable.delay.mass_invite(processed, current_user)
    end

    # # Adapters
    # TODO: This could be driven by a configuration or env.
    def adapter_class; Thinkspace::Importer::Uploaders::Adapters::Roster::S3; end

    # # Helpers
    def user_class; Thinkspace::Common::User; end
    def file_class; Thinkspace::Importer::File; end
    def storage_type; file_class.new.attachment.options[:storage]; end
    def storage_is_filesystem?; storage_type == :filesystem; end

    # # TODO:
    # def get_message_for_import_error(e=nil)
    #   return 'The provided file is not an accepted file type. Please submit a .csv file.' if e.is_a? invalid_record_error
    #   return 'The provided file has too few rows. Add more rows or invite users individually.' if e.is_a? not_enough_rows_error
    #   return 'The provided file has a row with no email. All rows must contain a valid email.' if e.is_a? unmatched_row_error
    #   return 'The provided file has a row with more than one email. All rows must contain only one email.' if e.is_a? overmatched_row_error
    #   return 'There was a problem processing the file. Please try again or contact support.'
    # end

  end
end; end; end