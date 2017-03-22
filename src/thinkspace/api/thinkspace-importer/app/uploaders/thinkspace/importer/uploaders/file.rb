module Thinkspace; module Importer; module Uploaders;
  class File < Thinkspace::Common::Uploaders::Base
    def file_class; Thinkspace::Importer::File; end

    def upload
      response = []
      files.each do |file|
        f = file_class.new(attachment: file)
        response.push(f) if f.save!
      end
      response
    end

    def authorize!
      raise_authorization_error("Cannot update Space [#{authable.id}]") unless current_ability.can?(:update, authable)
    end

  end
end; end; end