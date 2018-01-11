require 'spreadsheet'

module Thinkspace; module Casespace; module Exporters; class OwnerableData < Thinkspace::Common::Exporters::Base
  attr_reader :books, :options
  attr_reader :phase_class, :assignment_class, :workbook_class, :team_class, :user_class, :exporters_phase_score_class, :exporters_assignment_score_class

  attr_accessor :current_phases, :current_assignments, :current_ownerables

  def initialize(options={})
    @options                          = options
    @options[:is_test]                = Rails.env.development?
    @current_phases                   = Array.wrap(options[:phases])
    @current_assignments              = Array.wrap(options[:assignments])
    @current_ownerables               = Array.wrap(options[:ownerables])
    @books                            = Hash.new
    @phase_class                      = Thinkspace::Casespace::Phase
    @assignment_class                 = Thinkspace::Casespace::Assignment
    @workbook_class                   = Spreadsheet::Workbook
    @team_class                       = Thinkspace::Team::Team
    @user_class                       = Thinkspace::Common::User
    @exporters_phase_score_class      = Thinkspace::Casespace::Exporters::PhaseScore
    @exporters_assignment_score_class = Thinkspace::Casespace::Exporters::AssignmentScore
  end

  # ###
  # ### Class methods
  # ###

  # ### Report generators
  def self.generate(report)
    authable = report.authable
    return report.send_error_notification('NO_AUTH') unless authable.present?
    if authable.respond_to?(:export_all_ownerable_data)
      exporter = authable.export_all_ownerable_data
      exporter.save_file_for_report(report, authable) ? report.send_access_notification : report.send_error_notification('FILE_SAVE_FAIL')
    else
      report.send_error_notification('AUTH_NO_RESP')
    end
  end

  # ###
  # ### Instance methods
  # ###

  # ### Processing
  def process
    if is_for_assignments?
      process_assignments
    elsif is_for_phases?
      process_phases
    end
    write_files if options[:is_test]
    self
  end

  # ### Bulk processing
  def process_assignments
    current_assignments.each do |assignment|
      process_assignment(assignment)
    end
  end

  def process_phases
    current_phases.each do |phase|
      process_phase(phase)
    end
  end

  # ### Instance processing
  def process_assignment(assignment)
    if has_ownerables?
      ownerables = current_ownerables
    else
      ownerables = assignment.get_space.thinkspace_common_users
    end
    exporters_assignment_score_class.new(self, assignment, ownerables).process
    phases = assignment.thinkspace_casespace_phases.order(:position)
    phases.each do |phase|
      process_phase(phase)
    end
  end

  def process_phase(phase)
    if has_ownerables?
      ownerables = current_ownerables
    else
      if phase.is_team_based?
        assignment       = phase.thinkspace_casespace_assignment
        assignment_teams = assignment.thinkspace_team_teams
        phase_teams      = phase.thinkspace_team_teams
        phase_teams.present? ? ownerables = phase_teams : ownerables = assignment_teams
      else
        ownerables = phase.get_space.thinkspace_common_users
      end
    end
    export_phase_ownerable_data(phase, ownerables)
  end

  # ### Exportation
  def export_phase_ownerable_data(phase, ownerables)
    # Do not export phase scores for now, the new assignment scores will handle it.
    # exporters_phase_score_class.new(self, phase, ownerables).process
    export_phase_components(phase, ownerables)
  end

  def export_phase_components(phase, ownerables)
    book           = get_book_for_record(phase)
    components     = phase.thinkspace_casespace_phase_components
    componentables = components.map(&:componentable)
    componentables.each do |componentable|
      klass = get_exporter_class_for_componentable(componentable)
      next unless klass.present?
      klass.new(self, componentable, phase, ownerables).process
    end
  end

  # ###
  # ### Helpers
  # ###
  def is_for_assignments?; !current_assignments.empty?; end
  def is_for_phases?;      !current_phases.empty?;      end
  def has_ownerables?;     !current_ownerables.empty?;  end

  # ### File writing
  def write_files
    # TODO: THIS IS FOR TESTING ONLY!  NEEDS TO WRITE TO S3 FOR PRODUCTION!
    books.each do |key, book|
      path      = File.join(Rails.root, 'spreadsheets')
      filename  = Time.now.strftime('%Y-%m-%d_%H-%M-%S') + '.xls'
      full_path = "#{path}/#{filename}"
      book.write full_path
    end
  end

  def save_file_for_report(report, authable)
    # Authable will be a phase or an assignment.
    return report.send_error_notification('NO_AUTH') unless authable.present?
    book = get_book_for_record(authable)
    return report.send_error_notification('NO_BOOK_FOR_AUTH') unless book.present?
    contents = StringIO.new
    book.write contents
    contents.rewind # Very important, will not write the full file otherwise.
    options = {
      attachment:           contents,
      attachment_file_name: get_filename_for_report(report, authable)
    }
    report.add_file(options) ? true : report.send_error_notification('FILE_SAVE_FAIL')
  end

  def get_filename_for_report(report, authable)
    authable.respond_to?(:title) ? title = authable.title : title = 'data-dump'
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    filename  = "#{title}_student-data_#{timestamp}"
    sanitize_filename(filename) + '.xls'
  end


end; end; end; end
