module TestThinkspace
  module Authorization
    module ThinkspaceCasespace

      # ###
      # ### Main
      # ###

      def thinkspace_casespace_ability
        alias_action :index, :show, :select, :view, to: :read
        set_crud_alias_actions
        set_user_role(:all)
        thinkspace_common_ability
        thinkspace_casespace_teams
        thinkspace_casespace_ability_all
        thinkspace_casespace_ability_engines
      end

      # ###
      # ### Teams
      # ###

      def thinkspace_casespace_teams
        can [:read], thinkspace_team_team_category_class
        can [:read], thinkspace_team_team_user_class
        can [:read], thinkspace_team_team_viewer_class

        can [:crud], thinkspace_team_team_class
        can [:crud, :teams], thinkspace_team_team_set_class
        can [:teams_view, :team_users_view], thinkspace_team_team_class

        can [:create, :destroy], thinkspace_team_team_user_class
        can [:create, :destroy], thinkspace_team_team_teamable_class
        can [:create, :destroy], thinkspace_team_team_viewer_class

        # Comments
        can [:read_commenterable], thinkspace_common_user_class
        can [:read_commenterable], thinkspace_team_team_class
      end

      # ###
      # ### Casespace
      # ###
      #
      # Assignment and phase read/update abiilty is based its associated space's ability.

      def thinkspace_casespace_assignment_class;  Thinkspace::Casespace::Assignment; end
      def thinkspace_casespace_phase_class;       Thinkspace::Casespace::Phase; end

      def thinkspace_casespace_phase_score_class; Thinkspace::Casespace::PhaseScore; end
      def thinkspace_casespace_phase_state_class; Thinkspace::Casespace::PhaseState; end

      def thinkspace_casespace_ability_all
        can [:read, :phase_states],    thinkspace_casespace_assignment_class, thinkspace_casespace_assignment_read
        can [:read, :load, :submit],     thinkspace_casespace_phase_class, thinkspace_casespace_phase_read

        can [:read], thinkspace_casespace_phase_state_class
        can [:read], thinkspace_casespace_phase_score_class

        can [:read], Thinkspace::Casespace::PhaseTemplate
        can [:read], Thinkspace::Casespace::PhaseComponent

        # ###
        # ### Admin additions
        # ###
        can [:create], thinkspace_casespace_assignment_class # Create non-authed.
        can [:templates, :clone, :load, :update, :view, :roster, :phase_order, :delete], thinkspace_casespace_assignment_class, thinkspace_casespace_assignment_update 
        can [:templates, :clone, :update, :destroy, :componentables], thinkspace_casespace_phase_class, thinkspace_casespace_phase_update # Clone is not authed presently.
      end

      # ### Can Tools/Helpers/HelperEmbeds

      def thinkspace_casespace_ability_engines
        thinkspace_casespace_ability_resource
        thinkspace_casespace_ability_markup
        thinkspace_casespace_ability_gradebook
        thinkspace_casespace_ability_html
        thinkspace_casespace_ability_diagnostic_path
        thinkspace_casespace_ability_diagnostic_path_viewer
        thinkspace_casespace_ability_artifact
        thinkspace_casespace_ability_lab
        thinkspace_casespace_ability_observation_list
        thinkspace_casespace_ability_input_element
        thinkspace_casespace_ability_peer_assessment
        thinkspace_casespace_ability_simulation
      end

      # MARKUP
      def thinkspace_markup_comment_class; Thinkspace::Markup::Comment; end
      def thinkspace_markup_library_class; Thinkspace::Markup::Library; end
      def thinkspace_markup_library_comment_class; Thinkspace::Markup::LibraryComment; end

      def thinkspace_casespace_ability_markup
        can [:crud, :fetch], thinkspace_markup_comment_class
        can [:crud, :add_tag, :remove_comment_tag, :add_comment_tag, :fetch], thinkspace_markup_library_class
        can [:crud, :select], thinkspace_markup_library_comment_class
      end

      # RESOURCES
      def thinkspace_casespace_ability_resource
        can [:crud], Thinkspace::Resource::File
        can [:crud], Thinkspace::Resource::Link
        can [:crud], Thinkspace::Resource::Tag
        can [:read], Thinkspace::Resource::FileTag
        can [:read], Thinkspace::Resource::LinkTag
      end

      # GRADEBOOK
      def thinkspace_casespace_ability_gradebook
        can [:create],    thinkspace_casespace_phase_score_class
        can [:create],    thinkspace_casespace_phase_state_class
        can [:update],    thinkspace_casespace_phase_score_class,  thinkspace_casespace_phase_association_update
        can [:update],    thinkspace_casespace_phase_state_class,  thinkspace_casespace_phase_association_update
        can [:roster_update], thinkspace_casespace_phase_state_class,  thinkspace_casespace_phase_association_update

        can [:gradebook], thinkspace_casespace_phase_state_class,  thinkspace_casespace_phase_association_update
        can [:gradebook], thinkspace_casespace_phase_score_class,  thinkspace_casespace_phase_association_update

        can [:gradebook], thinkspace_casespace_assignment_class,   thinkspace_casespace_assignment_update
        can [:gradebook], thinkspace_common_user_class,            thinkspace_common_space_read_users
        can [:gradebook], thinkspace_team_team_class

        can [:manage_resources], thinkspace_casespace_assignment_class, thinkspace_casespace_assignment_update
      end

      # HTML
      def thinkspace_html_content_class; Thinkspace::Html::Content; end

      def thinkspace_casespace_ability_html
        can [:read, :update, :validate], thinkspace_html_content_class
      end

      # INPUT ELEMENTS
      def thinkspace_input_element_response_class; Thinkspace::InputElement::Response; end
      def thinkspace_input_element_element_class;  Thinkspace::InputElement::Element; end

      def thinkspace_casespace_ability_input_element
        can [:read], thinkspace_input_element_element_class
        can [:crud], thinkspace_input_element_response_class
        can [:carry_forward], thinkspace_input_element_response_class
      end

      # OBSERVATION LISTS
      def thinkspace_observation_list_list_class;             Thinkspace::ObservationList::List; end
      def thinkspace_observation_list_observation_class;      Thinkspace::ObservationList::Observation; end
      def thinkspace_observation_list_observation_note_class; Thinkspace::ObservationList::ObservationNote; end

      def thinkspace_casespace_ability_observation_list
        can [:read], thinkspace_observation_list_list_class
        can [:crud], thinkspace_observation_list_observation_class
        can [:crud], thinkspace_observation_list_observation_note_class
        # ### Admin additions
        can [:update], thinkspace_observation_list_list_class
      end

      def thinkspace_diagnostic_path_path_class;       Thinkspace::DiagnosticPath::Path; end
      def thinkspace_diagnostic_path_path_item_class;  Thinkspace::DiagnosticPath::PathItem; end

      # DIAGNOSTIC PATHS
      def thinkspace_casespace_ability_diagnostic_path
        can [:crud], thinkspace_diagnostic_path_path_class
        can [:bulk, :bulk_destroy], thinkspace_diagnostic_path_path_class
        can [:crud], thinkspace_diagnostic_path_path_item_class
      end

      # DIAGNOSTIC PATH VIEWERS
      def thinkspace_casespace_ability_diagnostic_path_viewer
        viewer = Thinkspace::DiagnosticPathViewer::Viewer
        can [:read], viewer    
      end

      # ARTIFACTS
      def thinkspace_casespace_ability_artifact
        bucket = Thinkspace::Artifact::Bucket
        file   = Thinkspace::Artifact::File
        can [:read],       bucket
        can [:view_users], bucket
        can [:crud],       file
        # ### Admin additions
        can [:update], bucket
      end

      # LAB
      def thinkspace_casespace_ability_lab
        chart       = Thinkspace::Lab::Chart
        category    = Thinkspace::Lab::Category
        result      = Thinkspace::Lab::Result
        observation = Thinkspace::Lab::Observation

        can [:create, :update], [observation]
        can [:read], [chart, category, result, observation]

        # ### Admin additions
        can [:load, :category_positions], chart
        can [:crud, :result_positions], category
        can [:create, :update, :destroy], result
      end

      # PEER ASSESSMENT
      def thinkspace_casespace_ability_peer_assessment
        assessment = Thinkspace::PeerAssessment::Assessment
        review_set = Thinkspace::PeerAssessment::ReviewSet
        team_set   = Thinkspace::PeerAssessment::TeamSet
        review     = Thinkspace::PeerAssessment::Review
        overview   = Thinkspace::PeerAssessment::Overview
        can [:read], assessment
        can [:read, :submit], review_set
        can [:crud], review
        can [:read], overview

        # ###
        # ### Admin additions
        # ###
        can [:approve, :teams, :fetch, :review_sets, :team_sets], assessment 
        can [:approve], review
        can [:approve], review_set
        can [:approve], team_set
      end

      # SIMULATION
      def thinkspace_casespace_ability_simulation
        simulation = Thinkspace::Simulation::Simulation
        can [:read], simulation
      end

      # ### Can Helpers

      def thinkspace_casespace_assignment_read
        {thinkspace_common_space: thinkspace_common_space_read}
      end

      def thinkspace_casespace_assignment_update
        {thinkspace_common_space: thinkspace_common_space_update}
      end

      def thinkspace_casespace_phase_read
        {thinkspace_casespace_assignment: thinkspace_casespace_assignment_read}
      end

      def thinkspace_casespace_phase_update
        {thinkspace_casespace_assignment: thinkspace_casespace_assignment_update}
      end

      def thinkspace_casespace_phase_association_read
        {thinkspace_casespace_phase: thinkspace_casespace_phase_read}
      end

      def thinkspace_casespace_phase_association_update
        {thinkspace_casespace_phase: thinkspace_casespace_phase_update}
      end


      def thinkspace_casespace_phases_association_read
        {thinkspace_casespace_phases: thinkspace_casespace_phase_read}
      end

      def thinkspace_casespace_phases_association_update
        {thinkspace_casespace_phases: thinkspace_casespace_phase_update}
      end

    end
  end
end
