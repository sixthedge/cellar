module Test; module Ability; module Controllers; module Thinkspace; module Authorization; module Api

  class AbilitiesController
    def setup_abilities_unauthorized_reader(route);     route.assert_authorized; end
    def setup_abilities_can_update_unauthorized(route); route.assert_authorized; end
    def after_save(route)
      user  = route.dictionary_user
      space = route.dictionary_space
      return if space.blank? || user.blank?
      params                = route.get_params
      auth                  = Hash.new
      auth[:ownerable_type] = user.class.name.underscore
      auth[:ownerable_id]   = user.id
      auth[:source]         = space.class.name.underscore.pluralize
      auth[:source_method]  = :spaces
      params[:auth]         = auth
    end
  end

  class MetadataController
    def after_save(route)
      user       = route.dictionary_user
      assignment = route.dictionary_assignment
      return if assignment.blank? || user.blank?
      params                = route.get_params
      auth                  = Hash.new
      auth[:ownerable_type] = user.class.name.underscore
      auth[:ownerable_id]   = user.id
      auth[:model_type]     = assignment.class.name.underscore
      auth[:model_id]       = assignment.id
      params[:auth]         = auth
    end
  end

end; end; end; end; end; end
