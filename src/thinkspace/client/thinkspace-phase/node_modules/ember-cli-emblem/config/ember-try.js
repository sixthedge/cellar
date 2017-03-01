module.exports = {
  scenarios: [
    {
      name: 'default',
      dependencies: { }
    },
    {
      name: 'Ember 1.10',
      dependencies: {
        'ember': '1.10.0'
      }
    },
    {
      name: 'Ember 1.13.11',
      dependencies: {
        'ember': '1.13.11'
      }
    },
    {
      name: 'Ember 2.0.2',
      dependencies: {
        'ember': '2.0.2'
      }
    },
    {
      name: 'Ember 2.1.1',
      dependencies: {
        'ember': '2.1.1'
      }
    },
    {
      name: 'ember-release',
      dependencies: {
        'ember': 'components/ember#release'
      },
      resolutions: {
        'ember': 'release'
      }
    },
    {
      name: 'ember-beta',
      dependencies: {
        'ember': 'components/ember#beta'
      },
      resolutions: {
        'ember': 'beta'
      }
    }
  ]
};
