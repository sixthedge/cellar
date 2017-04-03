module Thinkspace; module Common; module Uploaders;
  module Exceptions

    class UploaderError < StandardError; end
    class ParamsRecordError < UploaderError; end;
    class MethodNotImplementedError < UploaderError; end;
    class AuthorizationError < UploaderError; end

  end
end; end; end