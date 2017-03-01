module Totem
  module Core
    module Oauth

      class SoftError            < StandardError; end;

      class Error                < StandardError; end;
      class InvalidArgumentError < Error; end;
      class InvalidParamsError   < Error; end;
      class InvalidEmailError    < Error; end;
      class InvalidPlatformName  < Error; end;
      class InvalidOauthConfig   < Error; end;

      class PlatformApiBlank        < Error; end;
      class PlatformProvidersBlank  < Error; end;
      class PlatformNameBlank       < Error; end;

      class ConnectionError    < Error; end;
      class ConnectionRefused  < Error; end;

    end
  end
end
