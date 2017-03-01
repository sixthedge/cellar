require 'timetable_helper'
module Test; module Timetable; module Model; class PhaseTest < ActionController::TestCase
  include Timetable::Helpers::All

describe 'phases' do
  let (:current_user)    {get_user(:read_1)}
  let (:ownerable)       {current_user}
  let (:timeable)        {get_phase(:timetable_phase_1_A)}
  let (:assignment)      {get_assignment(:timetable_assignment_1)}
  let (:phases)          {assignment.thinkspace_casespace_phases.order(:id)}

  describe 'open' do
    it 'no owneable'      do; assert_open_phases_default_to_assignment; end
    it 'ownerable now'    do; assert_open_phases_with_ownerable; end
    it 'ownerable past'   do; assert_open_phases_with_ownerable(:past); end
    it 'ownerable future' do; assert_open_phases_with_ownerable(:future); end
    it 'assignment past due but phase A ownerable is open' do
      create_timetable(when: :past, timeable: assignment)
      create_ownerable_timetable
      expect = [timeable]
      actual = phases.scope_open(ownerable).to_ary
      assert_equal expect, actual, 'phase A still open'
    end
    it 'assignment past due but phases A and B with ownerable is open' do
      popen = get_phase(:timetable_phase_1_B)
      create_timetable(when: :past, timeable: assignment)
      create_ownerable_timetable
      create_ownerable_timetable(timeable: popen)
      expect = [timeable, popen]
      actual = phases.scope_open(ownerable).order(:id).to_ary
      assert_equal expect, actual, 'phases A and B still open'
    end
    it 'assignment open but phases A and C with ownerable are past due' do
      ppast = get_phase(:timetable_phase_1_C)
      create_ownerable_timetable(when: :past)
      create_ownerable_timetable(when: :past, timeable: ppast)
      expect = phases.order(:id).to_ary - [timeable, ppast]
      actual = phases.scope_open(ownerable).to_ary
      assert_equal expect, actual, 'phase B still open'
    end
  end

  describe 'next due at' do
    it 'no owneable - default to assignment' do
      expect = assignment.thinkspace_common_timetables.where(ownerable: nil).first.due_at
      actual = phases.next_due_at
      assert_times_equal expect, actual
    end
    it 'no ownerable - phase due at' do
      expect = time_now + 1.day
      create_timetable(due_at: expect)
      actual = phases.next_due_at
      assert_times_equal expect, actual
    end
    it 'ownerable - assignment due at - default for phase' do
      expect = time_now + 1.day
      create_timetable(timeable: assignment, due_at: expect)
      actual = phases.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
    it 'ownerable - phase due at - default for ownerable' do
      expect = time_now + 1.day
      create_timetable(due_at: expect)
      actual = phases.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
    it 'ownerable - phase ownerable due at' do
      expect = time_now + 1.day
      create_ownerable_timetable(due_at: expect)
      actual = phases.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
    it 'ownerable - phase due at - phase ownerable due at' do
      create_timetable(due_at: time_now + 1.day)
      expect = time_now + 2.days
      create_ownerable_timetable(due_at: expect)
      actual = phases.next_due_at(ownerable)
      assert_times_equal expect, actual
    end
  end

  describe 'release at and due at' do
    it 'no ownerable - default to assignment' do
      tt = timetable_class.where(timeable: assignment)
      assert_equal 1, tt.length, 'should be one timetable record'
      assert_times_equal tt.first.release_at, timeable.release_at
      assert_times_equal tt.first.due_at, timeable.due_at
    end
    it 'no ownerable - with phase timetable' do
      create_timetable
      tt = timetable_class.where(timeable: timeable)
      assert_equal 1, tt.length, 'should be one timetable record'
      assert_times_equal tt.first.release_at, timeable.release_at
      assert_times_equal tt.first.due_at, timeable.due_at
    end
    it 'no ownerable - with phase timetable - past' do
      create_timetable(when: :past)
      tt = timetable_class.where(timeable: timeable)
      assert_equal 1, tt.length, 'should be one timetable record'
      assert_times_equal tt.first.release_at, timeable.release_at
      assert_times_equal tt.first.due_at, timeable.due_at
    end
    it 'ownerable phase timetable' do
      ra = time_now - 1.minute
      da = time_now + 1.minute
      tt = create_ownerable_timetable(release_at: ra, due_at: da)
      assert_times_equal ra, timeable.release_at(ownerable)
      assert_times_equal da, timeable.due_at(ownerable)
    end
    it 'ownerable phase timetable - past' do
      ra, da = get_release_at_and_due_at(when: :past)
      create_ownerable_timetable(release_at: ra.utc, due_at: da.utc)
      assert_times_equal ra, timeable.release_at(ownerable)
      assert_times_equal da, timeable.due_at(ownerable)
      assert_equal true, (da < time_now.utc), 'due at in the past'
    end
  end

end; end; end; end; end
