totem_test_helper = ENV['TOTEM_TEST_HELPER']
$:.push(totem_test_helper)  unless $:.include?(totem_test_helper) # add totem's test_helper.rb to the load path before requiring it

require 'test_helper'
require 'pp'

require_relative '../../../../thinkspace-casespace/test/helpers/casespace_helper'
require_test_helper_files('../peer_assessment/helpers/route', engine: 'thinkspace-peer-assessment')
require_test_helper_files('../peer_assessment/helpers', engine: 'thinkspace-peer-assessment')
Test::Casespace::Seed.load(config: :peer_assessment)


def get_team_set(title, options={})
  options.merge!(title: title)
  team_set = team_set_class.find_by(options)
  raise "team_set title #{title.inspect} options #{options.inspect} not found."  if team_set.blank?
  team_set
end

def team_set_class; Thinkspace::Team::TeamSet; end

def assert_explode(team_set, transform)
  raise "team_set not provided for assert_explode" if team_set.blank?
  raise "transform not provided for assert_explode" if transform.blank?
  team_set.thinkspace_team_teams.each do |team|
    ids        = team.thinkspace_common_users.pluck(:id)
    trans_team = transform['teams'].find { |t| t['title'] == team.title }

    assert_presence trans_team, "trans_team is present for team #{team.title}"
    assert_equal ids.uniq.sort, trans_team['user_ids'].uniq.sort, "user ids are equal for team #{team.title}"
  end

  transform['teams'].each do |trans_team|
    ids  = trans_team['user_ids']
    team = team_set.thinkspace_team_teams.find_by(title: trans_team['title'])

    assert_presence team, "team is present for trans team #{trans_team['title']}"
    assert_equal ids.uniq.sort, team.thinkspace_common_users.pluck(:id).uniq.sort, "user ids are equal for team #{trans_team['title']}"
  end
end

# assert that the PE team_sets were reassigned to the correct team_ids
def assert_team_ids_reassigned(team_set)
  team_ids = team_set.thinkspace_team_teams.pluck(:id)
  get_assessment.thinkspace_peer_assessment_team_sets.each do |ts|
    assert_include team_ids, ts.team_id
  end
end

# assert that the reviews were reassigned to the correct reviewables
def assert_reviewables_on_team(team_set)
  team_set.thinkspace_team_teams.each do |team|
    members = team.thinkspace_common_users
    ts      = get_team_set_for_team(team)
    if ts.present?
      members.each do |member|
        rs = get_review_set_for_ownerable(ts, member)
        if rs.present?
          rs.thinkspace_peer_assessment_reviews.each do |review|
            assert_reviewable_on_team(review, members)
          end
        end
      end
    end
  end
end

def assert_reviewable_on_team(review, users)
  assert_include users, review.reviewable, "Reviewable with id #{review.reviewable_id} is on team"
end

def assert_presence(obj, message='')
  assert obj.present?, message
end

def assert_include(array, element, message='')
  assert array.include?(element), message
end

def get_team_set_for_team(team)
  Thinkspace::PeerAssessment::TeamSet.find_by(assessment_id: get_assessment.id, team_id: team.id)
end

def get_review_set_for_ownerable(team_set, ownerable)
  team_set.thinkspace_peer_assessment_review_sets.find_by(ownerable: ownerable)
end

def get_review_for_reviewable(review_set, reviewable)
  review_set.thinkspace_peer_assessment_reviews.find_by(reviewable: reviewable)
end

def get_assessment
  Thinkspace::PeerAssessment::Assessment.last
end

def generate_assessment_reviews(assessment)
  assessment.get_or_create_team_sets.each do |ts| 
    ts.get_or_create_review_sets.each do |rs|
      rs.create_reviews
    end
  end
end