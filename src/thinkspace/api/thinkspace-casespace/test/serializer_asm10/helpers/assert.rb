module Test::SerializerAsm10::Helpers::Assert
extend ActiveSupport::Concern
included do

  def assert_space_assignment_ids(json, space, assignments=[])
    ids  = [assignments].flatten.compact.map(&:id).sort
    hash = space_json(json)
    assert_json_assignment_association_ids(hash, ids)
    assert_json_space_id(hash, space)
  end

  def assert_assignment_space_id(json, space, assignment=nil)
    hash = assignment_json(json)
    assert_json_space_association_id(hash, space)
    assert_json_assignment_id(hash, assignment) if assignment.present?
  end

  def assert_assignments_space_id(json, spaces, assignments=[])
    spaces      = [spaces].flatten.compact.sort_by {|s| s.id}
    assignments = [assignments].flatten.compact.sort_by {|a| a.id}
    assignments_json(json).each_with_index do |hash, index|
      assert_json_space_association_id(hash, spaces[index])
      assert_json_assignment_id(hash, assignments[index]) if assignments.present?
    end
  end

  def assert_json_assignment_id(json, assignment)
    id = json['id']
    assert_equal assignment.id, id, "Should have correct user's assignment id"
  end

  def assert_json_assignment_association_ids(json, ids)
    assignment_ids = json[json_assignments_id_key].sort
    assert_equal ids, assignment_ids, "Should have correct assignment association ids"
  end

  def assert_json_space_id(json, space)
    id = json['id']
    assert_equal space.id, id, "Should have correct user's space id"
  end

  def assert_json_space_association_id(json, space)
    id = json[json_space_id_key]
    assert_equal space.id, id, "Should have correct user's space association id"
  end

  def json_space_id_key;       @_json_space_id_key       ||= space_class.name.underscore + '_id'; end
  def json_assignments_id_key; @_json_assignments_id_key ||= assignment_class.name.underscore + '_ids'; end

  def json_assignment_key;  assignment_class.name.underscore; end
  def json_assignments_key; json_assignment_key.pluralize; end

  def json_space_key;  space_class.name.underscore; end
  def json_spaces_key; json_space_key.pluralize; end

  def assignment_json(json);  json[json_assignment_key]  || Hash.new; end
  def assignments_json(json); (json[json_assignments_key] || Array.new).sort_by {|h| h['id']}; end

  def space_json(json);  json[json_space_key]  || Hash.new; end

end; end
