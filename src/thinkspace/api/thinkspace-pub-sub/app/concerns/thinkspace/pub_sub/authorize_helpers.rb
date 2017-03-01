module Thinkspace; module PubSub; module AuthorizeHelpers

  extend ::ActiveSupport::Concern

  included do

    def get_auth; params[:auth] || Hash.new; end

    def team?;           authable.is_a?(team_class); end
    def has_authable?;   get_auth[:authable_type].present? || get_auth[:authable_id].present?; end

    def space_class;      Thinkspace::Common::Space; end
    def assignment_class; Thinkspace::Casespace::Assignment; end
    def phase_class;      Thinkspace::Casespace::Phase; end
    def team_class;       Thinkspace::Team::Team; end

    # ###
    # ### Validate Rooms.
    # ###

    def validate_rooms(rooms, room_type=nil, arecord=nil, orecord=nil)
      return if tracker_room?(rooms, room_type) # allow tracker route room access since no model will be present
      arecord ||= authable
      orecord ||= ownerable
      can?(:update, arecord) ? validate_updater_rooms(rooms, room_type, arecord, orecord) : validate_reader_rooms(rooms, room_type, arecord, orecord)
    end

    def tracker_room?(rooms, room_type)
      room_type == 'tracker' && rooms == ['tracker_room']
    end

    # ###
    # ### Validate Updater Rooms.
    # ###

    # Updater rooms are valid if the rooms 'start with' a model path they can update.
    def validate_updater_rooms(rooms, room_type, arecord=authable, orecord=ownerable)
      models = get_valid_models_from_authable(arecord)
      access_denied "Unauthorized 'updater' server event rooms. Not a space, assignment or phase but #{arecord.class.name.inspect}." if models.blank?
      valid_rooms = get_rooms_for_models(models)
      return if invalid_start_with_rooms(rooms, valid_rooms).blank?  # often will be the space or assignment room so check first
      assignment = get_assignment_from_valid_models(models)
      access_denied "Unauthorized 'updater' server event rooms. Assignment is blank." if assignment.blank?
      phases      = get_room_assignment_phases(assignment)
      start_withs = phases.map {|p| pubsub.room_for(p)}
      access_denied "Unauthorized 'updater' server event rooms as no valid start-with rooms." if start_withs.blank?
      #invalid_rooms = invalid_start_with_rooms(rooms, start_withs)
      #access_denied "Unauthorized 'updater' server event rooms #{invalid_rooms}." if invalid_rooms.present?
    end

    def invalid_start_with_rooms(rooms, start_withs)
      invalid_rooms = Array.new
      Array.wrap(rooms).each do |room|
        valid = false
        Array.wrap(start_withs).each do |sw|
          valid = true if room.start_with?(sw)
          break if valid
        end
        invalid_rooms.push(room) unless valid
      end
      invalid_rooms
    end

    # ###
    # ### Validate Reader Rooms.
    # ###

    # Reader rooms must be a valid room.
    def validate_reader_rooms(rooms, room_type, arecord=authable, orecord=ownerable)
      models = get_valid_models_from_authable(arecord)
      access_denied "Unauthorized 'reader' server event rooms. Not a space, assignment or phase but #{arecord.class.name.inspect}." if models.blank?
      if room_type == 'tracker' # tracker rooms do not include the user/ownerable (user info is in data)
        valid_rooms = get_rooms_for_models(models)
        return if reader_rooms_valid?(valid_rooms, rooms)
        access_denied "Unauthorized 'reader' tracker rooms."
      end
      assignment = get_assignment_from_valid_models(models)
      access_denied "Unauthorized 'reader' server event rooms. Assignment is blank." if assignment.blank?
      valid_rooms = Array.new
      models.each do |model|
        valid_rooms += get_valid_reader_room_set(model, current_user)
        valid_rooms += get_valid_reader_room_set(model, orecord) unless orecord == current_user
      end
      reader_rooms_valid?(valid_rooms, rooms)
    end

    def reader_rooms_valid?(valid_rooms, rooms)
      Array.wrap(rooms).uniq.each do |room|
        access_denied "Unauthorized server event room #{room.inspect}." unless valid_rooms.include?(room)
      end
    end

    def get_valid_reader_room_set(arecord, orecord)
      access_denied "A valid room set required an authable."   if arecord.blank?
      access_denied "A valid room set required an ownerable."  if orecord.blank?
      access_denied "Not authorized to access rooms for #{arecrod.inspect}."  unless can?(:read, arecord)
      access_denied "Not authorized to access rooms for #{orecord.inspect}."  unless can?(:read, orecord)
      valid_rooms = [
        pubsub.room_with_ownerable(arecord, orecord),
        pubsub.room_with_ownerable(arecord, orecord, :server_event),
      ]
      valid_rooms
    end

    # ###
    # ### Validate Room Helpers.
    # ###

    def get_rooms_for_models(models); Array.wrap(models).map {|r| pubsub.room_for(r)}; end

    def get_valid_models_from_authable(arecord)
      case
      when arecord.is_a?(space_class)      then ([arecord] + get_room_space_assignments(arecord)).compact
      when arecord.is_a?(assignment_class) then [arecord.get_space, arecord].compact
      when arecord.is_a?(phase_class)      then [arecord.get_space, arecord.thinkspace_casespace_assignment, arecord].compact
      else null
      end
    end

    def get_assignment_from_valid_models(models)
      record = models.find {|r| r.is_a?(assignment_class) || r.is_a?(phase_class)}
      return nil if record.blank?
      record.is_a?(phase_class) ? record.thinkspace_casespace_assignment : record
    end

    def get_room_assignment_phases(assignment); assignment.thinkspace_casespace_phases.accessible_by(current_ability); end
    def get_room_space_assignments(space);      space.thinkspace_casespace_assignments.accessible_by(current_ability); end

    # ###
    # ### Authable/Ownerable.
    # ###

    def authable
      @authable ||= begin
        if totem_action_authorize?
          record = totem_action_authorize.record_authable
        else
          record = current_ability.get_authable_from_params_auth(params)
        end
        access_denied "Authable is blank."  if record.blank?
        record
      end
    end

    def ownerable
      @ownerable ||= begin
        if totem_action_authorize?
          record = totem_action_authorize.params_ownerable
        else
          record = current_ability.get_ownerable_from_params_auth(params)
        end
        access_denied "Ownerable is blank."  if record.blank?
        record
      end
    end

    # ###
    # ### Totem Action Authorize.
    # ###

    def new_totem_action_authorize(options={})
      auth_mod = get_action_authorize_module
      ::Totem::Core::Controllers::TotemActionAuthorize::Authorize.new(self, auth_mod, options)
    end

    def get_action_authorize_module
      access_denied "Authorize requires a params[:auth][:authable]."  unless authable.present?
      key = team? ? :action_authorize_teams : :action_authorize
      mod = ::Totem::Settings.module.send(:thinkspace).send(key)
      access_denied "Authorization module #{key.inspect} not found."  if mod.blank?
      mod
    end

    def totem_action_authorize?; self.send(:totem_action_authorize).present?; end

  end

end; end; end
