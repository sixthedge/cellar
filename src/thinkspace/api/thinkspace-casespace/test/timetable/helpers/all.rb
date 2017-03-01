module Test; module Timetable; module Helpers; module All
extend ActiveSupport::Concern
included do

  include Casespace::Models
  include Timetable::Helpers::Models
  include Timetable::Helpers::Assert

end; end; end; end; end
