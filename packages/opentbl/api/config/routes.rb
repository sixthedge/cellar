Rails.application.routes.draw do

  ::Totem::Core::Routes::Draw.new.draw(self)

end
