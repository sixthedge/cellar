module Thinkspace
  module Team
    class Team < ActiveRecord::Base
      # Scoped serializer attribute for the current user and team.
      def is_member(scope); self.thinkspace_team_team_users.where(user_id: scope.current_user.id).exists?; end

      totem_associations
      include AASM

      validates_presence_of :authable
      validates :title, presence: true #, uniqueness: {scope: [:authable_id, :authable_type]} TODO: Can't be used for assessment.

      # ###
      # ### State management
      # ###
      aasm column: :state do
        state :neutral, initial: true
        state :locked
        event :lock do
          transitions to: :locked
        end
      end

      # ###
      # ### General helpers
      # ###

      def add_teamables(teamables)
        teamables = Array.wrap(teamables)
        teamables.each do |teamable|
          thinkspace_team_team_teamables << Thinkspace::Team::TeamTeamable.new(teamable: teamable)
        end
      end

      # ###
      # ### Helper for scopes to allow ids or records to be passed as parameters.
      # ###
      def self.get_scope_ids(values)
        values = [values].flatten
        ids    = (values.first.respond_to?(:id) ? values.map(&:id) : values).uniq
        ids.length > 1 ? ids : ids.first
      end

      # ###
      # ### Scopes.
      # ###

      # ### Scope By
      def self.scope_by_title(title); where(title: title); end

      def self.scope_by_authables(authables)
        raise ScopeError, "Authables are blank."  if authables.blank?
        where(authable: authables)
      end

      def self.scope_by_teamables(teamables)
        raise ScopeError, "Teamables are blank." if teamables.blank?
        joins(thinkspace_team_team_set: :thinkspace_team_team_set_teamables).
        where(thinkspace_team_team_set_teamables: {teamable: teamables})        
      end

      def self.scope_by_teams(teams)
        raise ScopeError, "Teams are blank."  if teams.blank?
        where(id: get_scope_ids(teams))
      end

      def self.scope_by_users(users)
        raise ScopeError, "Users are blank."  if users.blank?
        joins(:thinkspace_team_team_users).
        where(thinkspace_team_team_users: {user_id: get_scope_ids(users)})
      end

      def self.scope_by_viewerables(viewerables)
        # raise ScopeError, "Viewerables are blank."  if viewerables.blank?
        joins(:thinkspace_team_team_viewers).
        where(thinkspace_team_team_viewers: {viewerable: viewerables})
      end

      def self.scope_viewerables_for_users(teamable, users)
        scope_by_teamables(teamable).scope_by_viewerables(users)
      end

      def self.scope_viewerables_for_users_teams(teamable, users)
        scope_by_teamables(teamable).scope_by_viewerables(users_teams(teamable, users))
      end

      # ### Scope User's Teamable Teams

      def self.users_teams(teamable, users)
        scope_by_teamables(teamable).
        scope_by_users(users)
      end

      def self.users_common_teams(teamable, users)
        team_ids = users_teams(teamable, users).pluck(:id)
        [users].flatten.each do |user|
          team_ids = team_ids & users_teams(teamable, user).pluck(:id)
        end
        where(id: team_ids)
      end

      # Combine teams a user can view either through another 'team' (they are a member) or
      # as a single 'user' viewer.
      def self.viewer_teams_for_users(teamable, users)
        (
          scope_viewerables_for_users(teamable, users).to_ary +
          scope_viewerables_for_users_teams(teamable, users).to_ary
        ).uniq
      end

      # ### Teamable teams exist? (returns true|false) e.g. user is collaboration team member or team can peer review another team.

      def self.can_view_users?(teamable, users); scope_viewerables_for_users(teamable, users).exists?; end
      def self.can_view_teams?(teamable, users); scope_viewerables_for_users_teams(teamable, users).exists?; end
      def self.users_can_view_teams?(users, teams); scope_by_users(users).scope_by_teams(teams).exists?; end

      def self.users_on_teams?(teamable, users, teams)
        users_teams(teamable, users).
        scope_by_teams(teams).
        exists?
      end

      def self.users_view_teams?(teamable, users, teams)
        return false if teams.blank?
        (Array.wrap(teams) - viewer_teams_for_users(teamable, users)).blank?
      end

      def self.users_view_users?(teamable, users, view_users)
        return false if view_users.blank?
        (viewer_teams_for_users(teamable, users) - viewer_teams_for_users(teamable, view_users)).blank?
      end

      # ###
      # ### State helpers
      # ###
      def self.state_locked; 'locked'; end

      # ###
      # ### Clone team.
      # ###

      # Clone options:   
      #   clone_include: deep_clone include hash (see deep_cloneable gem documentation)
      #   dictionary:    hash of record hashes used in the deep_clone
      #:                 root hash keys are the model_class_name.underscore.pluralize
      #:                 nested hash keys are the original records
      #:                 nested hash values are the originial record's cloned record
      #
      # All records are saved and returns the 'saved', cloned team (unless an exception is raised).
      #
      # If want the dictionary values (or want to provide a populated dictionary), pass the dictionary option into the method.
      # For example:
      #   dictionary   = team.get_clone_dictionary
      #   cloned_team  = team.cyclone(dictionary: dictionary)
      #

      # Class method to clone all teams from the source_teamable to the teamable.
      def self.cyclone(options={})
        source_teamable = options[:source_teamable]
        return if source_teamable.blank?
        teams        = self.scope_by_teamables(source_teamable)
        cloned_teams = Array.new
        self.transaction do
          teams.each do |team|
            cloned_teams.push team.cyclone(options)
          end
        end
        cloned_teams
      end

      def cyclone(options={})
        self.transaction do
          team_set                = options[:team_set]
          clone_include           = options[:clone_include] || get_clone_include(options)
          dictionary              = options[:dictionary]    || get_clone_dictionary
          title                   = options[:title] || self.title
          authable                = options[:authable]
          cloned_team             = self.deep_clone include: clone_include, dictionary: dictionary
          cloned_team.title       = title
          cloned_team.authable    = authable if authable.present?
          cloned_team.team_set_id = team_set.id if team_set.present?
          raise_clone_exception("Clone save error for team [id: #{self.id}] errors #{cloned_team.errors.full_messages.inspect}.") unless cloned_team.save
          cloned_team
        end
      end

      def clone_title(authable, options)
        # TODO: Not used presently, as duplicates should be allowed for assessment.
        title     = options[:title]            || self.title
        prefix    = options[:dup_title_prefix] || :clone
        number_of = options[:dup_title_tries]  || 5  # should be a reasonable limit on tries
        try_title = title
        (number_of + 1).times do |i|
          dup_team = self.class.scope_by_authables(authable).scope_by_title(try_title).exists?
          return try_title if dup_team.blank?
          try_title = (i == 0) ? "#{prefix} #{title}" : "#{prefix}-#{i+1} #{title}"
        end
        message = "Team clone error.  Title #{title.inspect} is a duplicate.  Tried #{number_of} times to generate a unique title [next try: #{try_title.inspect}] for [#{self.inspect}]."
        raise_clone_exception message
      end

      def get_clone_include(options)
        hash = Hash.new
        hash[:thinkspace_team_team_teamables] = []
        hash[:thinkspace_team_team_viewers]   = []  unless options[:team_viewers] == false
        hash[:thinkspace_team_team_users]     = []  unless options[:team_users] == false
        hash
      end

      def get_clone_dictionary
        dictionary = Hash.new
        dictionary
      end

      def raise_clone_exception(message)
        raise CloneError, message
      end

      class CloneError < StandardError; end
      class ScopeError < StandardError; end

   end
 end
end
