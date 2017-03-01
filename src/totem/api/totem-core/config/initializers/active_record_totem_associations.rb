ActiveRecord::Base.class_eval do
  def self.totem_associations(options={})
    env = options[:env] || ::Totem::Settings
    env.associations.perform(self, options)
  end
end
