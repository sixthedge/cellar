import ember  from 'ember';
import app_mixin  from './application_route_mixin';
import auth_mixin from 'ember-simple-auth/mixins/application-route-mixin';

// The totem application-route is in the 'application_route_mixin'.
// The addon 'ember-simple-auth' includes an 'routes/application.js' and
// if use 'routes/application.coffee' will cause a duplicate-file error.
// Therefore, using 'application.js' with the 'application_route_minin.coffee'.

export default ember.Route.extend(auth_mixin, app_mixin);
