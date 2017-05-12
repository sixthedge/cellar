module Test; module PhaseActions; module Helpers; module All
extend ActiveSupport::Concern
included do

  include Casespace::All
  include PhaseActions::Helpers::Actions
  include PhaseActions::Helpers::Assert
  include PhaseActions::Helpers::Ownerables
  include PhaseActions::Helpers::Submit

end; end; end; end; end
