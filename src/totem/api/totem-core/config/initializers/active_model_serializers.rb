ActiveModelSerializers::Adapter::JsonApi.class_eval do

  # Override this method to restrict which records to put in the json 'included' section.
  def process_relationships(serializer, include_directive)
    io    = serializer.send(:instance_options) || Hash.new
    scope = io[:scope] || Hash.new
    so    = scope[:serializer_options]
    serializer.associations(include_directive).each do |association|
      next unless so && so.include_association?(serializer, association.name)
      inc_dir = JSONAPI::IncludeDirective.new('*', allow_wildcard: true) # include all and let serializer_options exclude
      process_relationship(association.serializer, inc_dir)
    end
  end

  # Remove _id(s) from association.key.
  # e.g. thinkspace/common/spaces vs thinkspace/common/space_ids
  # ember-data expects the relationship keys to match the ember-data model association.
  def relationships_for(serializer, requested_associations)
    include_directive = JSONAPI::IncludeDirective.new(
      requested_associations,
      allow_wildcard: true
    )
    serializer.associations(include_directive).each_with_object({}) do |association, hash|
      key       = association.key.to_s.sub('_id','')  # need to keep the slashed version of the key (e.g. not the name)
      hash[key] = ::ActiveModelSerializers::Adapter::JsonApi::Relationship.new(serializer, instance_options, association).as_json
    end
  end

end
