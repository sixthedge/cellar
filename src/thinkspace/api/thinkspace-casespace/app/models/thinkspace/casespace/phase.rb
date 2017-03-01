module Thinkspace
  module Casespace
    class Phase < ActiveRecord::Base
      def active;         self.active?; end
      def team_ownerable; self.team_ownerable?; end
      def team_set_id;               get_team_set_id; end
      def due_at(ownerable=nil);     get_timetable_value(ownerable, :due_at); end
      def release_at(ownerable=nil); get_timetable_value(ownerable, :release_at); end
      def unlock_at(ownerable=nil);  get_timetable_value(ownerable, :unlock_at); end

      totem_associations

      #validates :title, presence: true, uniqueness: {scope: [:thinkspace_casespace_assignment]}

      # => Returns a timetable column value for a single record (e.g. not a scope).
      def get_timetable_value(ownerable=nil, col); self.class.timetable_scope(ownerable).value(self.id, col); end

      def get_val; self.class.timetable_scope(nil).value(self.id, :due_at, :release_at); end

      # ###
      # ### Scopes.
      # ###

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      def self.scope_completed(ownerable)
        scope_phase_states_by_ownerable(ownerable).
        where(thinkspace_casespace_phase_states: {current_state: 'completed'})
      end

      def self.scope_phase_states_by_ownerable(ownerable)
        joins(:thinkspace_casespace_phase_states).
        where(thinkspace_casespace_phase_states: {ownerable_id: ownerable.id}).
        where(thinkspace_casespace_phase_states: {ownerable_type: ownerable.class.name})
      end

      def self.scope_phase_scores_by_ownerable(ownerable)
        phase_state_ids = scope_phase_states_by_ownerable(ownerable).pluck('thinkspace_casespace_phase_states.id')
        Thinkspace::Casespace::PhaseScore.where(phase_state_id: phase_state_ids)
      end

      def self.phase_timetables_maximum_updated_at(ownerables=nil, options={})
        tts = timetable_scope(ownerables)
        tts.with_scope.scope_open(ownerables, tts).maximum(tts.coalesce(:updated_at))
      end

      # ###
      # ### Timetable Scopes.
      # ###

      def self.timetable_scope(ownerables=nil); Thinkspace::Common::Timetable::Scope.new(self, ownerables, 'Thinkspace::Casespace::Assignment'); end

      def self.next_due_at(ownerables=nil)
        tts = timetable_scope(ownerables)
        tts.with_scope.scope_open(ownerables,tts).minimum(tts.coalesce(:due_at))
      end

      def self.scope_open(ownerables=nil, tts=nil)
        (tts || timetable_scope(ownerables)).
        where_now('<=', :release_at).
        with_scope.
        scope_active
      end

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        state :archived
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
        event :archive do; transitions to: :archived; end
      end

      # ###
      # ### Helpers.
      # ###

      def authable; self; end

      def get_space; thinkspace_casespace_assignment.get_space; end

      def get_configuration; thinkspace_common_configuration || Thinkspace::Common::Configuration.create(configurable: self); end

      # ###
      # ### Componentable helpers
      # ###
      def get_builder_abilities
        # Default abilities (can perform all, will be overriden by componentables if needed).
        abilities = {
          default_state:          true,
          max_score:              true,
          auto_score:             true,
          unlock_phase:           true,
          complete_phase:         true,
          configuration_validate: true,
          team_based:             true,
          team_category:          true,
          team_set:               true
        }
        componentables = thinkspace_casespace_phase_components.map(&:componentable)
        componentables.each do |componentable|
          next unless componentable.respond_to?(:builder_abilities)
          abilities = componentable.builder_abilities(abilities)
        end
        abilities
      end

      # ###
      # ### Team Helpers.
      # ###

      def get_team_set_id
        teamable = self.thinkspace_team_team_set_teamables.reload.first
        teamable.blank? ? nil : teamable.thinkspace_team_team_set.id
      end

      def team_category;   self.thinkspace_team_team_category; end
      def team_ownerable?; category = team_category; category.present? && category.team_ownerable?; end
      def peer_review?;    category = team_category; category.present? && category.peer_review?; end
      def collaboration?;  category = team_category; category.present? && category.collaboration?; end

      def get_teams(ownerable=nil)
        if ownerable.blank?
          teams = self.thinkspace_team_teams
        else
          case
          when ownerable.is_a?(user_class)
            teams = self.thinkspace_team_teams.scope_by_users(ownerable)
          when ownerable.is_a?(team_class)
            teams = self.thinkspace_team_teams.scope_by_teams(ownerable)
          else
            raise PhaseTeamError, "Ownerable class must be a user or team not #{ownerable.class.name.inspect}."
          end
        end
        teams + self.thinkspace_casespace_assignment.get_teams(ownerable)
      end

      def assign_team_set(team_set)
        raise PhaseTeamError, "Cannot assign a team set without a valid team set." unless team_set.present?
        raise PhaseTeamError, "Phase's space and team set's space do not match."   unless self.get_space == team_set.get_space
        team_set.assign_to_record(self)
      end

      def unassign_team_set
        Thinkspace::Team::TeamSet.unassign_all_from_record(self)
      end

      def user_class; Thinkspace::Common::User; end
      def team_class; Thinkspace::Team::Team; end

      class PhaseTeamError < StandardError; end

      # ###
      # ### Phase State.
      # ###

      def get_phase_states(ownerable, user, options={})
        phase_states = Array.new
        get_ownerables(ownerable, user, options).each do |phase_ownerable|
          phase_states.push find_or_create_state_for_ownerable(phase_ownerable, user)
        end
        phase_states.flatten.compact.uniq
      end

      def get_ownerables(ownerable, user, options={})
        can_update = options[:can_update] || false
        ownerables = get_base_ownerables(ownerable, user, options)
        # Only add a 'user' ownerable phase_state if is an updater on a collaboration team phase
        # and getting phase states for themselves.  The updater needs the team phase user phase state
        # so can view the phase and view other users (e.g. gradebook).
        ownerables.push(ownerable) if can_update && self.team_ownerable? && ownerable == user
        ownerables
      end

      def get_base_ownerables(ownerable, user, options={})
        case
        when self.team_ownerable?        then get_teams(ownerable)
        when ownerable.is_a?(user_class) then Array.wrap(ownerable)
        when ownerable.is_a?(team_class) then Array.new
        else
          raise PhaseOwnerableError, "Ownerable class must be a user or team not #{ownerable.class.name.inspect}."
        end
      end

      def find_or_create_state_for_ownerable(ownerable, user=nil)
        state = thinkspace_casespace_phase_states.find_by(ownerable: ownerable)
        if state.blank?
          state = thinkspace_casespace_phase_states.create(
            ownerable:     ownerable,
            user_id:       user && user.id,
            current_state: get_default_state
          )
          raise FindOrCreateError, "Could not find or create phase state for phase [errors: #{state.errors.messages}] [#{self.inspect}] [ownerable: #{ownerable.inspect}]."  if state.errors.present?
        end
        raise FindOrCreateError, "Could not find or create phase state for phase [phase: #{self.inspect}] [ownerable: #{ownerable.inspect}]."  unless state.present?
        state
      end

      def get_default_state
        has_unlock_at_and_is_unlocked? ? 'unlocked' : self.default_state
      end

      def unlock_valid_locked_ownerable_phase_states(tt_ids, tt=nil, validate=true)
        # Note: Has to be tt_ids instead of the ActiveRecord::Relation directly, since it is delayed/serialized.
        if validate
          return if tt_ids.empty?
          return unless unlock_at.present? && unlock_at <= Time.now
        end
        tts               = Thinkspace::Common::Timetable.where(id: tt_ids)
        team_ids          = thinkspace_common_timetables.scope_by_teams.pluck(:ownerable_id)
        user_ids          = thinkspace_common_timetables.scope_by_users.pluck(:ownerable_id)
        team_phase_states = thinkspace_casespace_phase_states.scope_by_not_team_ownerable_ids(team_ids)
        user_phase_states = thinkspace_casespace_phase_states.scope_by_not_user_ownerable_ids(user_ids)
        unlock_phase_states(team_phase_states)
        unlock_phase_states(user_phase_states)
        tt.set_unlocked_at if tt.present?
      end

      def unlock_for_ownerable(ownerable, tt, validate=true)
        if validate
          return unless ownerable.present? && tt.present?
          return unless tt.unlock_at <= Time.now
        end
        time         = Time.now
        phase_states = thinkspace_casespace_phase_states.scope_by_ownerables(ownerable, self).scope_locked
        unlock_phase_states(phase_states) if phase_states.present?
        tt.set_unlocked_at
      end

      def unlock_phase_states(phase_states)
        return unless phase_states.present?
        return unless phase_states.respond_to?(:update_all)
        phase_states.update_all(current_state: 'unlocked', updated_at: Time.now)
      end

      def has_unlock_at_and_is_unlocked?
        unlock_at.present? && unlock_at <= Time.now
      end

      class PhaseOwnerableError < StandardError; end

      # ###
      # ### Phase Score.
      # ###

      def find_or_create_score_for_ownerable(ownerable, user=nil)
        phase_state = find_or_create_state_for_ownerable(ownerable, user)
        score       = phase_state.thinkspace_casespace_phase_score
        if score.blank?
          score = phase_state.create_thinkspace_casespace_phase_score(
            user_id: user && user.id,
            score:   0,
          )
        end
        raise FindOrCreateError, "Could not find or create phase score for phase state [phase_state: #{phase_state.inspect}] [ownerable: #{ownerable.inspect}]."  unless score.present?
        score
      end

      class ScopeError        < StandardError; end
      class FindOrCreateError < StandardError; end

      # ###
      # ### Clone Phase.
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      # Clone options:
      #   assignment:    assignment record to override the phase.assignment_id
      #   ownerable:     set a cloned record's ownerable to this ownerable record (phase and nested records)
      #   user|user_id:  set a cloned record's user_id to this record's id (phase and nested records)
      #   dictionary:    hash of record hashes used in the deep_clone
      #:                 root hash keys are the model_class_name.underscore.pluralize
      #:                 nested hash keys are the original records
      #:                 nested hash values are the originial record's cloned record
      #
      #   boolean options (default true if not specified):
      #     clone_phase_template: (will not clone a 'domain' template)
      #     clone_configuration:
      #     clone_resources:
      #     clone_teams:
      #
      # If want the dictionary values (or want to provide a populated dictionary), pass the dictionary option into the method.
      # For example:
      #   dictionary   = phase.get_clone_dictionary
      #   cloned_phase = phase.cyclone(dictionary: dictionary)
      #
      def cyclone(options={})
        self.transaction do
          assignment              = options[:assignment] # specific assignment override
          clone_associations      = get_clone_associations(options)
          options[:authable]      = self
          options[:dictionary]    ||= get_clone_dictionary(options)
          #
          # Clone the phase.
          #
          cloned_phase               = clone_self(options, clone_associations)
          cloned_phase.title         = get_clone_title(self.title, options)
          cloned_phase.assignment_id = assignment.id  if assignment.present?
          cloned_phase.position      = clone_position(cloned_phase, options)
          cloned_phase.state         = self.state
          clone_save_record(cloned_phase)
          #
          # Post clone phase: clone the cloned phase's phase_component componentables, phase template, teams, etc..
          #
          clone_phase_template(cloned_phase, options)   if clone_include?(:clone_phase_template, options)
          clone_phase_component_componentables(cloned_phase, options)
          clone_phase_resources(options)                if clone_include?(:clone_resources, options)
          clone_phase_teams(options)                    if clone_include?(:clone_teams, options)

          cloned_phase
        end
      end

      private

      def get_clone_associations(options={})
        clone_associations = [:thinkspace_casespace_phase_components]
        clone_associations.push(:thinkspace_common_configuration)  if clone_include?(:clone_configuration, options)
        clone_associations.push(:thinkspace_casespace_assignment)  if is_full_clone?(options)
        clone_associations
      end

      def clone_position(phase, options={})
        position = options[:position]
        return position  if position.present?
        assignment = phase.thinkspace_casespace_assignment
        position   = assignment.thinkspace_casespace_phases.maximum(:position)
        position.blank? ? 1 : position + 1
      end

      def clone_phase_template(cloned_phase, options={})
        dictionary = get_clone_dictionary(options)
        template   = self.thinkspace_casespace_phase_template
        raise_clone_exception("Clone phase phase_template not found [id: #{self.id}].") if template.blank?
        return if template.domain == true
        cloned_template       = template.deep_clone include: [], dictionary: dictionary
        cloned_template.title = options[:template_title] || cloned_phase.title + ' - ' + cloned_template.title
        cloned_template.name  = options[:template_name]  || (cloned_phase.title.downcase + '_' + cloned_template.name).gsub(/\s/,'_').gsub(/\W/, '')
        clone_save_record(cloned_template)
        cloned_phase.phase_template_id = cloned_template.id
        clone_save_record(cloned_phase)
      end

      def clone_phase_component_componentables(cloned_phase, options={})
        method = :cyclone
        get_cloned_phase_components_in_order_of_clone(cloned_phase).each do |cloned_phase_component|
          componentable = cloned_phase_component.componentable
          next unless componentable.respond_to?(method, true)
          cloned_componentable = componentable.send(method, options)
          if cloned_componentable.present?
            cloned_phase_component.componentable = cloned_componentable
            clone_save_record(cloned_phase_component)
          else
            raise_clone_exception("Phase component componentable #{componentable.class.name.inspect} did not return a clone.")
          end
        end
      end

      def get_cloned_phase_components_in_order_of_clone(cloned_phase)
        do_last    = Array.new
        components = Array.new
        cloned_phase.thinkspace_casespace_phase_components.each do |cloned_phase_component|
          componentable = cloned_phase_component.componentable
          next if componentable.blank?
          if componentable.is_a?(self.class)
            # If the componentable is the phase (e.g. header, submit) set the 'cloned_phase_component'
            # componentable to the cloned phase, save and skip to next (e.g. don't re-clone the phase).
            cloned_phase_component.componentable = cloned_phase
            clone_save_record(cloned_phase_component)
            next
          end
          if componentable.respond_to?(:clone_last) && componentable.clone_last
            do_last.push(cloned_phase_component)
          else
            components.push(cloned_phase_component)
          end
        end
        components + do_last
      end

      include Thinkspace::Resource::Concerns::Clone::Resources
      include Thinkspace::Team::Concerns::Clone::Teams

      def clone_phase_resources(options={}); clone_record_resources(self, get_clone_dictionary(options), options); end

      def clone_phase_teams(options={})
        # TODO: This should clone the configuration options essentially for team_set and team_type
        return
      end
      # ###
      # ### Delete Ownerable Data.
      # ###

      include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      def ownerable_data_associations; [:thinkspace_casespace_phase_states]; end

      public

      def delete_all_ownerable_data!
        self.transaction do
          delete_ownerable_data_scope_all
          method = :delete_all_ownerable_data!
          delete_componentables_ownerable_data(method)
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          delete_ownerable_data_scope_by_ownerables(ownerables)
          method = :delete_ownerable_data
          delete_componentables_ownerable_data(method, ownerables)
        end
      end

      def delete_componentables_ownerable_data(method, ownerables=nil)
        self.thinkspace_casespace_phase_components.each do |phase_component|
          componentable = phase_component.componentable
          next if componentable.blank?
          next if componentable.is_a?(self.class)  # don't call the phase again
          next unless componentable.respond_to?(method, true)
          ownerables.present? ? componentable.send(method, ownerables) : componentable.send(method)
        end
      end

      # ###
      # ### Export Ownerable Data.
      # ###
      def export_all_ownerable_data(options={})
        processor = Thinkspace::Casespace::Exporters::OwnerableData.new(phases: self)
        processor.process
      end

      def export_ownerable_data(ownerables, options={})
        processor = Thinkspace::Casespace::Exporters::OwnerableData.new(phases: self, ownerables: ownerables)
        processor.process
      end

      # ###
      # ### Submit Event Management.
      # ###
      protected

      # TODO: Implement setting to check for 'allow completed changes', for now they can due to tickets.
      def self.read_states;       ['unlocked', 'completed']; end
      def self.modify_states;     ['unlocked', 'completed']; end
      def self.admin_only_states; ['locked']; end

      def add_auto_score_event(options)
        return unless options.has_key?(:phase_id)
        phase_id = options.delete(:phase_id)
        event    = {phase_id: phase_id, event: :auto_score}
        add_submit_event(event, options)
      end

      def add_complete_phase_event(options)
        return unless options.has_key?(:phase_id)
        phase_id = options.delete(:phase_id)
        event    = {phase_id: phase_id, event: :complete_phase}
        add_submit_event(event, options)
      end

      def add_unlock_phase_event(options)
        return unless options.has_key?(:phase_id)
        phase_id = options.delete(:phase_id)
        event    = {phase_id: phase_id, event: :unlock_phase}
        add_submit_event(event, options)
      end

      def get_submit_settings
        settings = get_configuration.settings.with_indifferent_access
        Array.wrap(settings[:action_submit_server])
      end

      private

      def add_submit_event(event, options = {})
        configuration   = get_configuration
        submit_settings = get_submit_settings
        if options[:force_single]
          submit_settings.each { |setting| submit_settings.delete(setting) if setting[:event].to_sym == event[:event].to_sym }
        end
        submit_settings.push(event)
        new_settings = configuration.settings.with_indifferent_access
        new_settings[:action_submit_server] = submit_settings
        configuration.settings = new_settings
        configuration.save
      end

    end
  end
end
