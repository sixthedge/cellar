module Thinkspace; module PeerAssessment; module Exporters; class Qualitative < Thinkspace::PeerAssessment::Exporters::Assessment
  attr_reader   :book
  attr_accessor :sheet, :current_row

  def initialize(caller, assessment, phase, users)
    super(caller, assessment, phase, users)
    @book        = @caller.get_book_for_record(@phase)
    @current_row = 1 # Allow for headers on 0.
  end

  def process
    @sheet       = get_qualitative_sheet
    add_headers_to_sheet(@sheet)
    @teams.each do |team|
      process_team(team)
    end 
  end

  def process_team(team)
    # Goal is to create an array of arrays that represents each student's reviews.
    # The output will be something like:
    # 
    # reviewer   | qual_label | qual_label
    # teammate_1 | value      | value
    # teammate_2 | value      | value
    #
    # Each "section" will be separated by a blank row for readability. 
    users = get_ordered_users_for_team(team)
    users.each   do |user|
      process_user(user)
    end
  end

  def process_user(user)
    # `user` is the student who we are listing their qualitative reviews for.
    review_set = get_review_set_for_ownerable(user)
    return unless review_set.present?
    reviews    = review_set.thinkspace_peer_assessment_reviews
    return unless reviews.present?
    rows       = []
    rows.push(get_header_row_for_user(user))
    reviews.each do |review|
      add_review_data_to_rows(rows, review)
    end
    add_rows_to_sheet(rows)
  end

  # # Helpers
  # ## Sheets
  def get_headers_for_sheet
    identifiers = get_sheet_header_identifiers
    identifiers.push('Team Name')
    identifiers
  end 

  # ## Rows
  def add_review_data_to_rows(rows, review)
    reviewable = review.reviewable
    return unless reviewable.present?
    row = caller.get_ownerable_identifiers(reviewable)
    row.push(get_team_title_for_user(reviewable))
    @assessment.qualitative_item_ids.each do |id|
      value = review.qualitative_value_for_id(id)
      row.push(value)
    end
    rows.push(row)
  end

  def add_rows_to_sheet(rows)
    rows.each do |r|
      @sheet.update_row @current_row, *r
      @current_row += 1
    end
    @current_row +=1 # Add a blank row.
  end

  # ## Getters
  def get_header_row_for_user(user)
    row  = caller.get_ownerable_identifiers(user)
    row.push(get_team_title_for_user(user))
    get_assessment_labels.each { |label| row.push(label) }
    row
  end

  def get_team_title_for_user(user)
    team = get_team_for_user(user)
    team.present? ? team.title : ''
  end

  def get_assessment_labels
    @assessment.qualitative_items.map { |i| i['label'] }
  end

  def get_qualitative_sheet
    title = 'Qualitative'
    caller.find_or_create_worksheet_for_phase(@book, @phase, title)
  end

  def get_ordered_users_for_team(team)
    team.thinkspace_common_users.order(:last_name)
  end

  def get_review_set_for_ownerable(ownerable)
    @review_sets.find_by(ownerable: ownerable)
  end

end; end; end; end
