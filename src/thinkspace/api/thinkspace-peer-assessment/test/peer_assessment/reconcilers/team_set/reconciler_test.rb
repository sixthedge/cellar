require 'peer_assessment_helper'

module Test; module Reconcilers; class TeamSetReconciler < ActiveSupport::TestCase

  describe "reconcile team_sets" do

    let (:team_set) {get_team_set(:team_set_1)}
    let (:assessment) {get_assessment}


    describe "1 single user move" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = team_set.transform.deep_dup
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "2 single user swap" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 1, title: 'team_123', user_ids: [3,4,6]}, {id: 2, title: 'team_456', user_ids: [5,7,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "3 multi user move" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 1, title: 'team_123', user_ids: []}, {id: 2, title: 'team_456', user_ids: [3,4,5,6,7,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "4 multi user swap" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 1, title: 'team_123', user_ids: [3,6,7]}, {id: 2, title: 'team_456', user_ids: [4,5,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "5 users unassigned" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 1, title: 'team_123', user_ids: []}, {id: 2, title: 'team_456', user_ids: [6,7,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "6 team deleted" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 2, title: 'team_456', user_ids: [6,7,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "7 team deleted and users moved" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 2, title: 'team_456', user_ids: [3,4,6,7,8]}, {id: 3, title: 'team_789', user_ids: [5,9,10,11]}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

    describe "8 team created and users moved" do
      it "reconcile" do
        generate_assessment_reviews(assessment)
        transform    = { teams: [{id: 1, title: 'team_123', user_ids: [4,5]}, {id: 2, title: 'team_456', user_ids: [6,7,8]}, {id: 3, title: 'team_789', user_ids: [9,10,11]},{id: 189327493845, title: 'team_10', user_ids: [3], new: true}]}
        transform = JSON.parse(transform.to_json)
        team_set.transform = transform
        team_set.save
        new_team_set = team_set.explode
        assert_explode new_team_set, transform
        assert_team_ids_reassigned new_team_set
        assert_reviewables_on_team new_team_set
      end
    end

  end


end; end; end
