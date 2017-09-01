require 'spreadsheet'

module Thinkspace; module PeerAssessment; module Exporters; class Assessment < Thinkspace::Common::Exporters::Base
  attr_reader :caller, :assessment, :phase, :assignment, :space, :teams, :users, :team_sets, :review_sets, :reviews

  def initialize(caller, assessment, phase, users)
    @caller      = caller
    @assessment  = assessment
    @phase       = phase
    @assignment  = phase.thinkspace_casespace_assignment
    @space       = @assignment.thinkspace_common_space
    @users       = users.order(:last_name).uniq
    @team_sets   = assessment.thinkspace_peer_assessment_team_sets
    team_ids     = @team_sets.pluck(:team_id).uniq
    @teams       = Thinkspace::Team::Team.where(id: team_ids).order(:title)
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
    process_qualitative
  end

  def process_ownerable(ownerable, index, sheet)
    row_number  = index + 1 # Offset by 1 due to header row
    team        = get_team_for_user(ownerable)
    identifiers = caller.get_ownerable_identifiers(ownerable)
    identifiers.push(team.title) if team.present?
    # first_name, last_name, email, team_name, score(s)... are headers.
    return sheet.update_row(row_number, *(identifiers), '', '') unless team.present?

    data = get_anonymized_review_json_for_ownerable(ownerable)
    return sheet.update_row(row_number, *(identifiers), '', '') if data.empty?

    scores = []

    @assessment.quantitative_items.each do |quant_item|
      id    = quant_item['id'].to_s # question ids are saved as integers on the assessment, but represented as strings in the anonymized json
      scores << get_score_for_question(data, id)
    end
    add_totals_to_scores(scores)  
    sheet.update_row row_number, *(identifiers), *scores
  end

  def process_qualitative
    exporter = Thinkspace::PeerAssessment::Exporters::Qualitative.new(@caller, @assessment, @phase, @users)
    exporter.process
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

  def add_totals_to_scores(scores)
    return if scores.empty?
    scores  = Array.wrap(scores)
    total   = scores.inject(0) { |sum, x| sum + x }.to_f
    average = total / scores.length
    scores.push(nil) # Add an empty column for padding.
    scores.push(total.round(2))
    scores.push(average.round(2))
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
    # End result is:
    # last_name, first_name, email, team_name, qual..., BLANK, total, average
    if @assessment.quantitative_items.length > 1
      headers = []
      @assessment.quantitative_items.each_with_index do |item, index|
        number = index + 1 # Index starts at 0
        label  = item['label']
        headers.push("#{number}: #{label}")
      end
    else
      headers = [get_sheet_header_score]
    end
    identifiers = get_sheet_header_identifiers
    identifiers.push('Team Name')
    headers.unshift *(identifiers)
    headers.push(nil) # Empty column for spacing
    headers.push('Total')
    headers.push('Average')
  end 

  def add_headers_to_sheet(sheet)
    add_header_format(sheet)
    headers = get_headers_for_sheet
    caller.add_header_to_sheet(sheet, *headers)
  end

  def add_header_format(sheet)
    format  = ::Spreadsheet::Format.new(weight: :bold)
    sheet.row(0).default_format = format # Make the header bold.
  end

end; end; end; end
