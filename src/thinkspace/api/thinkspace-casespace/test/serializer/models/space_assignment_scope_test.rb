require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelsSpaceAssignment < ActionController::TestCase
  include Controller
  include Model
  include Assert

  # Test the ability and metadata serializer options are scoped correctly.

  def assignment_association; :thinkspace_casespace_assignments; end
  def space_ability;       {space_read: true, scope: :root}; end
  def assignment_ability;  {assignment_read: true, scope: assignment_association}; end
  def space_metadata;      {scope: :root}; end
  def assignment_metadata; {scope: assignment_association}; end

  describe @spaces_controller do
    let(:user)   {serializer_update_user}
    describe 'models..scope..space..assignment..no cache' do
      let(:record) {serializer_space}
      let(:action) {:show}

      it 'with ability' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(space_ability)
        serializer_options.include_ability(assignment_ability)
        json = serialize
        assert_with_ability_without_metadata(json)
        assert_ability_json(json, record, user, space_ability)
        assert_ability_json(json, record.send(assignment_association), user, assignment_ability)
      end

      it 'with assignment ability only' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(assignment_ability)
        json = serialize
        assert_with_ability_without_metadata(json)
        refute_ability_json(json, record, user)
        assert_ability_json(json, record.send(assignment_association), user, assignment_ability)
      end

      it 'with metadata' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_metadata(space_metadata)
        serializer_options.include_metadata(assignment_metadata)
        json = serialize
        assert_without_ability_with_metadata(json)
        assert_metadata_json(json, record, user, space_metadata_value, except: :next_due_at)
        assert_metadata_json(json, record.send(assignment_association), user, assignment_metadata_value)
      end

      it 'with assignment metadata only' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_metadata(assignment_metadata)
        json = serialize
        assert_without_ability_with_metadata(json)
        refute_metadata_json(json, record, user)
        assert_metadata_json(json, record.send(assignment_association), user, assignment_metadata_value)
      end

      it 'with ability..with metadata' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(space_ability)
        serializer_options.include_ability(assignment_ability)
        serializer_options.include_metadata
        json = serialize
        assert_with_ability_with_metadata(json)
        assert_ability_json(json, record, user, space_ability)
        assert_ability_json(json, record.send(assignment_association), user, assignment_ability)
        assert_metadata_json(json, record, user, space_metadata_value, except: :next_due_at)
        assert_metadata_json(json, record.send(assignment_association), user, assignment_metadata_value)
      end

      it 'with space ability..with space metadata' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(space_ability)
        serializer_options.include_metadata(space_metadata)
        json = serialize
        assert_with_ability_with_metadata(json)
        assert_ability_json(json, record, user, space_ability)
        refute_ability_json(json, record.send(assignment_association), user)
        assert_metadata_json(json, record, user, space_metadata_value, except: :next_due_at)
        refute_metadata_json(json, record.send(assignment_association), user)
      end

      it 'with assignment ability..with assignment metadata' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(assignment_ability)
        serializer_options.include_metadata(assignment_metadata)
        json = serialize
        assert_with_ability_with_metadata(json)
        refute_ability_json(json, record, user)
        assert_ability_json(json, record.send(assignment_association), user, assignment_ability)
        refute_metadata_json(json, record, user)
        assert_metadata_json(json, record.send(assignment_association), user, assignment_metadata_value)
      end

      it 'with space ability..with assignment metadata' do
        serializer_options.include_association(assignment_association)
        serializer_options.include_ability(space_ability)
        serializer_options.include_metadata(assignment_metadata)
        json = serialize
        assert_with_ability_with_metadata(json)
        assert_ability_json(json, record, user, space_ability)
        refute_ability_json(json, record.send(assignment_association), user)
        refute_metadata_json(json, record, user)
        assert_metadata_json(json, record.send(assignment_association), user, assignment_metadata_value)
      end

    end
  end

end; end; end
