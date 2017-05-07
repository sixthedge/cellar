require 'timetable_helper'
module Test; module Timetable; module Model; class AssignmentTest < ActionController::TestCase
  include Timetable::Helpers::All

describe 'assignments' do
  let (:current_user)    {get_user(:read_1)}
  let (:ownerable)       {current_user}
  let (:timeable)        {get_assignment(:timetable_assignment_1)}
  let (:space)           {get_space(:timetable_space)}
  let (:assignments)     {space.thinkspace_casespace_assignments}

  describe 'open' do
    it 'no owneable'      do; assert_open_assignments; end
    it 'ownerable now'    do; assert_open_assignments_with_ownerable; end
    it 'ownerable past'   do; assert_open_assignments_with_ownerable(:past); end
    it 'ownerable future' do; assert_open_assignments_with_ownerable(:future); end
    it 'multiple past' do
      pasta = get_assignment(:timetable_assignment_2)
      create_ownerable_timetable(when: :past)
      create_ownerable_timetable(when: :past, timeable: pasta)
      expect = assignments - [timeable, pasta]
      actual = assignments.scope_open(ownerable).to_ary
      assert_equal expect, actual, 'not include past assignments'
    end
    it 'multiple past-future' do
      pasta = get_assignment(:timetable_assignment_2)
      create_ownerable_timetable(when: :future)
      create_ownerable_timetable(when: :past, timeable: pasta)
      expect = assignments - [timeable, pasta]
      actual = assignments.scope_open(ownerable).to_ary
      assert_equal expect, actual, 'not include past/future assignments'
    end
  end

  describe 'next due at' do
    it 'no ownerable' do
      expect = timetable_class.where(timeable: assignments).minimum(:due_at)
      actual = assignments.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
    it 'ownerable' do
      expect = time_now + 1.hour
      create_ownerable_timetable(due_at: expect)
      actual = assignments.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
  end

  describe 'release at and due at' do
    it 'no ownerable' do
      tt = timetable_class.where(timeable: timeable)
      assert_equal 1, tt.length, 'should be one timetable record'
      assert_times_equal tt.first.release_at, timeable.release_at
      assert_times_equal tt.first.due_at, timeable.due_at
    end
    it 'ownerable' do
      ra = time_now - 1.minute
      da = time_now + 1.minute
      create_ownerable_timetable(release_at: ra.utc, due_at: da.utc)
      assert_times_equal ra, timeable.release_at(ownerable)
      assert_times_equal da, timeable.due_at(ownerable)
    end
  end

end; end; end; end; end
