module TestThinkspace
  module Authorization
    module ThinkspaceTeam

      def thinkspace_team_team_class;          Thinkspace::Team::Team; end
      def thinkspace_team_team_set_class;      Thinkspace::Team::TeamSet; end
      def thinkspace_team_team_category_class; Thinkspace::Team::TeamCategory; end
      def thinkspace_team_team_user_class;     Thinkspace::Team::TeamUser; end
      def thinkspace_team_team_teamable_class; Thinkspace::Team::TeamTeamable; end
      def thinkspace_team_team_viewer_class;   Thinkspace::Team::TeamViewer; end

    end
  end
end
