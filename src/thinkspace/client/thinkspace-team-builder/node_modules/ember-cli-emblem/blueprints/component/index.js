module.exports = {
  description: 'Generates a component. Name must contain a hyphen.',
  availableOptions: [
    {
      name: 'path',
      type: String,
      default: 'components',
      aliases:[
        {'no-path': ''}
      ]
    }
  ],
  locals: function(options) {
    return this.lookupBlueprint('component').locals(options);
  },
  fileMapTokens: function() {
    return this.lookupBlueprint('component').fileMapTokens();
  }
};
