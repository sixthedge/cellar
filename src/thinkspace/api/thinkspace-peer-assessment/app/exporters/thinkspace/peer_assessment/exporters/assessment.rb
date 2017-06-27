require 'spreadsheet'

module Thinkspace; module PeerAssessment; module Exporters; class Assessment < Thinkspace::Common::Exporters::Base
  attr_reader :caller, :assessment, :phase, :assignment, :teams, :users, :team_sets, :review_sets, :reviews

  def initialize(caller, assessment, phase, teams)
    @caller      = caller
    @assessment  = assessment
    @phase       = phase
    @assignment  = phase.thinkspace_casespace_assignment
    @teams       = teams.order(:title)
    @users       = phase.get_space.thinkspace_common_users.order(:last_name).uniq
    @team_sets   = assessment.thinkspace_peer_assessment_team_sets
    @review_sets = review_set_class.scope_by_team_sets(@team_sets)
    @reviews     = review_class.scope_by_review_sets(@review_sets)
  end

  def process
    book   = caller.get_book_for_record(@phase)
    sheet  = caller.find_or_create_worksheet_for_phase(book, @phase, 'Scores')
    add_headers_to_sheet(sheet)

    @users.each_with_index do |ownerable, index|
      process_ownerable(ownerable, index, sheet)
    end
  end

  def process_ownerable(ownerable, index, sheet)
    row_number = index + 1 # Offset by 1 due to header row
    team       = get_team_for_user(ownerable)
    return sheet.update_row(row_number, *(caller.get_ownerable_identifiers(ownerable)), 'N/A') unless team.present?

    data = get_anonymized_review_json_for_ownerable(ownerable)
    return sheet.update_row(row_number, *(caller.get_ownerable_identifiers(ownerable)), 'N/A') if data.empty?

    @assessment.quantitative_items.each do |quant_item|
      id    = quant_item['id'].to_s # question ids are saved as integers on the assessment, but represented as strings in the anonymized json
      score = get_score_for_question(data, id)
      sheet.update_row row_number, *(caller.get_ownerable_identifiers(ownerable)), score
    end
  end

  # ### Helpers
  def get_team_for_user(user) 
    team_class.users_teams(@phase, user).first
  end

  def get_team_set_for_team(team)
    @team_sets.find_by(team_id: team.id)
  end

  def get_anonymized_review_json_for_ownerable(ownerable)
    team              = get_team_for_user(ownerable)
    team_set          = get_team_set_for_team(team)
    return Hash.new unless team_set.present?

    other_review_sets = @review_sets.scope_by_team_sets(team_set).scope_where_not_ownerable_ids(ownerable).scope_submitted
    reviews           = @reviews.scope_by_review_sets(other_review_sets).scope_by_reviewable(ownerable)
    data              = review_class.generate_anonymized_review_json(@assessment, reviews)
  end

  def get_score_for_question(data, id)
    return data[:quantitative][id] if data[:quantitative].has_key?(id)
    'N/A'
  end

  # ### Classes
  def review_set_class; Thinkspace::PeerAssessment::ReviewSet; end
  def review_class;     Thinkspace::PeerAssessment::Review;    end
  def team_class;       Thinkspace::Team::Team;                end
  def user_class;       Thinkspace::Common::User;              end

  private

  # ### Sheet Helpers
  def get_sheet_header_identifiers; caller.get_sheet_header_identifiers(user_class.name); end
  def get_sheet_header_score;      'Score';                            end
  def wrap_in_quotes(str);         '"' + str + '"';                    end  

  def get_headers_for_sheet
    if @assessment.quantitative_items.length > 1
      headers = @assessment.quantitative_items.map { |q| q['label'] }
    else
      headers = [get_sheet_header_score]
    end
    headers.unshift *(get_sheet_header_identifiers)
    headers
  end 

  def add_headers_to_sheet(sheet)
    headers = get_headers_for_sheet
    caller.add_header_to_sheet(sheet, *headers)
  end   

end; end; end; end