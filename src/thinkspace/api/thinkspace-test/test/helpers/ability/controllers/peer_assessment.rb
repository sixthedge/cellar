module Test; module Ability; module Controllers; module Thinkspace; module PeerAssessment; module Api

  class AssessmentsController
    def setup_view_can_update_authorized(route); route.assert_unauthorized(/no teams found/i); end
    def params_view(route); route.set_params_sub_action(:teams); end
  end
  class OverviewsController
    def setup_view_can_update_authorized(route); route.assert_unauthorized(/no teams found/i); end
    def params_view(route); route.set_params_sub_action(:reviews); end
  end
  class ReviewsController
    def setup_create_can_update_authorized(route); route.assert_unauthorized(/reviewable without a valid team/i); end
  end

  module Admin
    class AssessmentsController
      def setup_fetch_can_update_authorized(route);       route.assert_raise_any_error(/couldn't find.*assignment with 'id'/i); end
      def setup_review_sets_can_update_authorized(route); route.assert_raise_any_error(/undefined.*authable/i); end
    end

    # TODO: Are these correct for an unauthorized user?
    class ReviewsController
      def setup_approve_can_update_unauthorized(route); route.assert_authorized; end
    end
    class ReviewSetsController
      def setup_approve_can_update_authorized(route);   route.assert_unauthorized(/invalid state transition/i); end
    end
    class TeamSetsController
      def setup_approve_can_update_unauthorized(route); route.assert_authorized; end
    end
  end

end; end; end; end; end; end
