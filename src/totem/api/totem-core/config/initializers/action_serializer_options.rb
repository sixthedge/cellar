if defined? ActionController::Base
  ActionController::Base.class_eval do
    include ::Totem::Core::Controllers::TotemActionSerializerOptions
  end
end

