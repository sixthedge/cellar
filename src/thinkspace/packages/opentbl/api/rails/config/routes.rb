Rails.application.routes.draw do

  # ### totem ### #
  concern :totem, Totem::Core::Routes::Engines.new(platform_name: 'totem'); concerns [:totem]

  # ### thinkspace ### #
  concern :thinkspace, Totem::Core::Routes::Engines.new(platform_name: 'thinkspace'); concerns [:thinkspace]


  root to: 'totem/core/application#serve_index_from_redis'  # added by totem

end
