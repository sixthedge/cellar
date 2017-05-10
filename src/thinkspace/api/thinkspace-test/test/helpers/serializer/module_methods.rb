module Test::Serializer::ModuleMethods

  extend ActiveSupport::Concern
  included do
    def ability_module;  ::Test::Serializer::ModuleMethods; end
    def metadata_module; ::Test::Serializer::ModuleMethods; end
    def spaces_module_ability_hash;  {module: ability_module,  method: :ability_spaces}; end
    def spaces_module_metadata_hash; {module: metadata_module, method: :metadata_spaces}; end
  end


  def self.ability_spaces(*args)
    {spaces: true, ability: true}
  end

  def self.metadata_spaces(*args)
    {spaces: true, metadata: true}
  end

end
