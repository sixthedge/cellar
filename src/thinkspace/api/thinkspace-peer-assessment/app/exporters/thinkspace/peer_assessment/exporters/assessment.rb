require 'spreadsheet'

module Thinkspace; module Casespace; module Exporters; class AssignmentScore < Thinkspace::Common::Exporters::Base
  attr_reader :caller, :assessment, :phase, :assignment, :teams, :users, :team_sets, :review_sets, :reviews

  def initialize(caller, assessment, phase, teams)
    @caller      = caller
    @assessment  = assessment
    @phase       = phase
    @assignment  = phase.thinkspace_casespace_assignment
    @teams       = teams
    @users       = phase.get_space.thinkspace_common_users
    @team_sets   = assessment.thinkspace_peer_assessment_team_sets
    @review_sets = review_set_class.scope_by_team_sets(@team_sets)
    @reviews     = review_class.scope_by_review_sets(@review_sets)
  end

  def process
    book   = caller.get_book_for_record(@phase)
    sheet  = caller.find_or_create_worksheet_for_phase(book, @phase, 'Scores')
    caller.add_header_to_sheet(sheet, get_sheet_header_identifier, get_sheet_header_score)
    scope = @phase.class.where(id: phase.id)
    @users.each_with_index do |ownerable, index|
      review_set        = get_review_set_for_ownerable(ownerable)
      team_set          = review_set.thinkspace_peer_assessment_team_set
      other_review_sets = @review_sets.scope_by_team_sets(team_set).scope_where_not_ownerable_ids(ownerable).scope_submitted
      reviews           = @reviews.scope_by_review_sets(other_review_sets).scope_by_reviewable(ownerable)
      data              = review_class.generate_anonymized_review_json(@assessment, reviews)
      row_number        = index + 1 # Offset by 1 due to header row
      if @assessment.is_balance_points?
        raise NoQuantitativeData, "No quantitative data found on peer assessment #{@assessment.id} for ownerable #{ownerable.inspect}" unless data.has_key?(:quantitative)
        score       = 0
        question_id = data[:quantitative].keys.pop
        score       = data[:quantitative][question_id]
        sheet.update_row row_number, caller.get_ownerable_identifier(ownerable), score
      else
        # TODO: Categories
      end
    end
  end

  # ### Helpers
  def get_review_set_for_ownerable(ownerable)
    @review_sets.find_by(ownerable: ownerable)
  end

  # ### Classes
  def review_set_class; Thinkspace::PeerAssessment::ReviewSet; end
  def review_class;     Thinkspace::PeerAssessment::Review;    end

  # ### Errors
  class NoQuantitativeData < StandardError; end

  private

  def get_sheet_header_identifier; caller.get_sheet_header_identifier; end
  def get_sheet_header_score;      'Score';                            end

end; end; end; end