module Test; module Ability; module Controllers; module Thinkspace; module DiagnosticPath; module Api

  module DiagnosticPathHelper
    def observation_class;    ::Thinkspace::ObservationList::Observation; end
    def list_class;           ::Thinkspace::ObservationList::List; end
    def path_item_class;      ::Thinkspace::DiagnosticPath::PathItem; end
  end

  class PathItemsController
    include DiagnosticPathHelper
    def before_save_create(route)
      user      = route.dictionary_user
      path_item = route.dictionary_model(path_item_class)
      list      = list_class.new
      route.save_model(list)
      obs = observation_class.new(user_id: user.id, ownerable: user, list_id: list.id)
      route.save_model(obs)
      route.add_model_to_dictionary(obs)
      route.add_model_to_dictionary(list)
      path_item.path_itemable = obs
    end
  end

end; end; end; end; end; end
