module Thinkspace; module Common; module Exporters
class Base
  # ### Filename helpers
  def sanitize_filename(filename)
    # TODO: Pull out into a common helper.
    # Reference: http://stackoverflow.com/questions/1939333/how-to-make-a-ruby-string-safe-for-a-filesystem
    filename.gsub!(/^.*(\\|\/)/, '')
    filename.gsub!(/[^0-9A-Za-z.\-]/, '_')
  end

  # ### Header helpers
  def add_header_to_sheet(sheet, *args)
    sheet.update_row 0, *args
  end

  def get_sheet_header_identifier; 'Identifier'; end

  # ### Find or create helpers
  def find_or_create_worksheet_for_phase(book, phase, additions)
    name  = standard_sheet_name_for_record(phase, additions)
    find_or_create_worksheet_for_name(book, name)
  end

  def find_or_create_worksheet_for_assignment(book, assignment, additions)
    name = standard_sheet_name_for_record(assignment, additions)
    find_or_create_worksheet_for_name(book, name)
  end

  def find_or_create_worksheet_for_name(book, name)
    name.gsub!(/[^0-9a-z\s-]/i, '')
    sheet = book.worksheet name
    sheet.present? ? sheet : book.create_worksheet(name: name)
  end

  # ### Sheet/book helpers
  def get_book_for_record(record)
    assignment = record.thinkspace_casespace_assignment if record.is_a?(phase_class)
    assignment = record if record.is_a?(assignment_class)
    book       = books[assignment]
    return book if book.present? && book.is_a?(workbook_class)
    # Create a new book for the assignment if it does not exist.
    book              = workbook_class.new
    books[assignment] = book
    book
  end

  def standard_sheet_name_for_record(record, additions='')
    # TODO: Why doesn't record.is_a?(Class) work here anymore?
    case
    when record.class.name == phase_class.name
      name = get_sheet_name_for_phase(record, additions)  
    when record.class.name == assignment_class.name
      name = get_sheet_name_for_assignment(record, additions)

    end
    name
  end

  def get_sheet_name_for_phase(phase, additions)
    "#{phase.position} - #{phase.title} - #{additions}"
  end

  def get_sheet_name_for_assignment(assignment, additions)
    "#{assignment.title} - #{additions}"
  end  

  # ### Exporters class finding
  def get_exporter_class_for_componentable(componentable)
    return nil unless componentable.present?
    name  = componentable.class.name
    parts = name.split('::')
    model = parts.pop
    klass = parts.join('::')
    return nil unless klass.present?
    klass = "#{klass}::#{get_exporter_namespace}::#{model}"
    get_exporter_class_from_name(klass)
  end

  def get_exporter_class_from_name(name)
    name.safe_constantize
  end

  def get_exporter_namespace; 'Exporters'; end

  # ### Ownerable helpers
  def get_ownerable_identifier(ownerable)
    ownerable.is_a?(team_class) ? ownerable.title : ownerable.email
  end

end; end; end; end