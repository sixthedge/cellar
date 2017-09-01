module Totem
  module Authentication
    module Lti

          class LtiError < StandardError; end

          class LtiCredentialsError                  < LtiError; end
          class LtiCredentialsInvalid                < LtiCredentialsError; end
          class LtiCredentialsInvalidPassword        < LtiCredentialsError; end
          class LtiCredentialsInvalidIdentification  < LtiCredentialsError; end

          class LtiTimeError    < LtiError; end
          class LtiTimeoutError < LtiTimeError; end
          class LtiExpiredError < LtiTimeError; end

          class LtiAuthenticationError   < LtiError; end
          class LtiUserError             < LtiAuthenticationError; end
          class LtiCreateError           < LtiAuthenticationError; end
          class LtiSaveError             < LtiAuthenticationError; end
          class LtiMissingIdentification < LtiAuthenticationError; end
          class LtiMissingAuthToken      < LtiAuthenticationError; end
          class LtiInvalidUserAuthToken  < LtiAuthenticationError; end
          class LtiInvalidUser           < LtiAuthenticationError; end
          class LtiInvalidIdentification < LtiAuthenticationError; end
          class LtiSignOutError          < LtiAuthenticationError; end

          class LtiUserClassError  < LtiError; end
          class LtiApiSessionClass < LtiError; end

    end
  end
end
