require 'timetable_helper'
module Test; module Timetable; module Model; class AssociationHashTest < ActionController::TestCase
  include Timetable::Helpers::All

describe 'phases' do
  let (:current_user)    {get_user(:read_1)}
  let (:ownerable)       {current_user}
  let (:timeable)        {get_phase(:timetable_phase_1_A)}
  let (:assignment)      {get_assignment(:timetable_assignment_1)}
  let (:space)           {get_space(:timetable_space)}
  let (:phases)          {assignment.thinkspace_casespace_phases}

  describe 'hash' do
    it 'no ownerable - phase gets space timetable' do
      expect = Time.parse('1111-11-11')
      create_timetable(timeable: space, due_at: expect)
      timetable_class.where(timeable: assignment).delete_all
      tts    = timetable_scope_class.new(timeable.class, nil, assignment_class, {on: assignment_class, for: space.class})
      actual = tts.select_virtual(:due_at).with_scope.where(id: timeable.id).map(&:v_due_at)
      assert_equal [expect], actual, "get the space timetable due at '#{expect}'"
    end
    it 'ownerable - phase gets space timetable' do
      expect = Time.parse('1111-11-11')
      create_timetable(timeable: space)
      create_ownerable_timetable(timeable: space, due_at: expect)
      timetable_class.where(timeable: assignment).delete_all
      tts    = timetable_scope_class.new(timeable.class, ownerable, assignment_class, {on: assignment_class, for: space.class})
      actual = tts.select_virtual(:due_at).with_scope.where(id: timeable.id).map(&:v_due_at)
      assert_equal [expect], actual, "get the space ownerable timetable due at '#{expect}'"
    end
    it 'ownerable - string association class names' do
      expect = Time.parse('1111-11-11')
      create_timetable(timeable: space)
      create_ownerable_timetable(timeable: space, due_at: expect)
      timetable_class.where(timeable: assignment).delete_all
      tts    = timetable_scope_class.new(timeable.class, ownerable, assignment_class.name, {on: assignment_class.name, for: space.class.name})
      actual = tts.select_virtual(:due_at).with_scope.where(id: timeable.id).map(&:v_due_at)
      assert_equal [expect], actual, "get the space ownerable timetable due at '#{expect}'"
    end
  end

  describe 'association classes' do
    it 'no ownerable - strings' do
      expect = Time.parse('1111-11-11')
      create_timetable(due_at: expect)
      tts    = timetable_scope_class.new(timeable.class, nil, assignment_class.name, {on: assignment_class.name, for: space.class.name})
      actual = tts.select_virtual(:due_at).with_scope.where(id: timeable.id).map(&:v_due_at)
      assert_equal [expect], actual, "get same result when use stings class names instead of classes"
    end
    it 'ownerable - strings - includes slash format' do
      expect = Time.parse('1212-12-12')
      create_ownerable_timetable(due_at: expect)
      tts    = timetable_scope_class.new(timeable.class, ownerable, assignment_class.name, {on: assignment_class.name.underscore, for: space.class.name})
      actual = tts.select_virtual(:due_at).with_scope.where(id: timeable.id).map(&:v_due_at)
      assert_equal [expect], actual, "get same result when use stings class names instead of classes"
    end
  end

end; end; end; end; end
