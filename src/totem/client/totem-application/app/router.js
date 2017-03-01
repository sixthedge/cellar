import Ember  from 'ember';
import config from './config/environment';
import totem_routes from 'totem-config/routes';

// The addon 'ember-simple-auth' includes a 'router.js' and
// if use 'router.coffee' will cause a duplicate-file error.

var Router = Ember.Router.extend({location: config.locationType});

Router.map(function() {totem_routes.map(this);});

export default Router;
