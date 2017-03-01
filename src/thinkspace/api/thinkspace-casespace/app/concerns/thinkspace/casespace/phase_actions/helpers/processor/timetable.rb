module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Timetable

  def timetable(timeable, options={})
    release_at = options[:release_at]
    due_at     = options[:due_at]
    return if release_at.blank? && due_at.blank?
    all        = (options[:all] == true)
    user       = options[:user]
    ownerables = options[:ownerable] || options[:ownerables]
    if all
      update_timetable_timeable_for_all(timeable, ownerables, user, release_at, due_at)
    else
      update_timetable_timeable_for_ownerables(timeable, ownerables, user, release_at, due_at)
    end
  end

  def update_timetable_timeable_for_all(timeable, ownerables, user, release_at, due_at)
    tt = timetable_class.find_or_create_timetable(timeable)
    update_timetable_record(tt, user, release_at, due_at)
    return if ownerables.blank?
    # Also update any ownerable specfic timetable records.
    tts = timetable_class.scope_by_timeable_ownerables(timeable, ownerables)
    tts.each do |tt|
      update_timetable_record(tt, user, release_at, due_at)
    end
  end

  def update_timetable_timeable_for_ownerables(timeable, ownerables, user, release_at, due_at)
    return if ownerables.blank?
    ownerables.each do |ownerable|
      tt = timetable_class.find_or_create_timetable(timeable, ownerable: ownerable)
      update_timetable_record(tt, user, release_at, due_at)
    end
  end

  def update_timetable_record(tt, user, release_at, due_at)
    return if release_at.blank? && due_at.blank?
    tt.user_id    = user.id     if user.present?
    tt.release_at = release_at  if release_at.present?
    tt.due_at     = due_at      if due_at.present?
    raise TimetableSaveError, "Error saving timetable [errors: #{tt.errors.messages}]." unless tt.save
  end

  def timetable_class; ::Thinkspace::Common::Timetable; end

  class TimetableSaveError < StandardError; end

end; end; end; end; end; end
