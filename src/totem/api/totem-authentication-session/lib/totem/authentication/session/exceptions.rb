module Totem
  module Authentication
    module Session

          class SessionError < StandardError; end

          class SessionCredentialsError                  < SessionError; end
          class SessionCredentialsInvalid                < SessionCredentialsError; end
          class SessionCredentialsInvalidPassword        < SessionCredentialsError; end
          class SessionCredentialsInvalidIdentification  < SessionCredentialsError; end

          class SessionTimeError    < SessionError; end
          class SessionTimeoutError < SessionTimeError; end
          class SessionExpiredError < SessionTimeError; end

          class SessionAuthenticationError   < SessionError; end
          class SessionUserError             < SessionAuthenticationError; end
          class SessionCreateError           < SessionAuthenticationError; end
          class SessionSaveError             < SessionAuthenticationError; end
          class SessionMissingIdentification < SessionAuthenticationError; end
          class SessionMissingAuthToken      < SessionAuthenticationError; end
          class SessionInvalidUserAuthToken  < SessionAuthenticationError; end
          class SessionInvalidUser           < SessionAuthenticationError; end
          class SessionInvalidIdentification < SessionAuthenticationError; end
          class SessionSignOutError          < SessionAuthenticationError; end

          class SessionUserClassError  < SessionError; end
          class SessionApiSessionClass < SessionError; end

    end
  end
end
