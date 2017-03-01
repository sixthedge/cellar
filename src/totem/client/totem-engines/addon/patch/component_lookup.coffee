import ember from 'ember'

# Allow non-dashed component names by removing the 'assert' error.
export default ->
    ember.ComponentLookup.reopen
      componentFor: (name, owner, options) ->
        fullName = 'component:' + name;
        return owner._lookupFactory(fullName, options)

      layoutFor: (name, owner, options) ->
        templateFullName = 'template:components/' + name;
        return owner.lookup(templateFullName, options)
