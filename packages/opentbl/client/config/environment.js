/* jshint node: true */

module.exports = function(environment) {

  var ENV = {
    "modulePrefix": "orchid",
    "rootURL":      "/",
    "locationType": "auto",
    "EmberENV":     {
        "ENABLE_DS_FILTER": true,
        "FEATURES": {
        }
    }
  }

  ENV.environment            = environment;
  ENV.EmberENV.PLATFORM_NAME = ENV.modulePrefix;
  ENV.APP                    = {};

  ENV.i18n = {
    "defaultLocale": "en"
  }

  ENV['ember-simple-auth'] = {
    "authenticationRoute": "login",
    "routeAfterAuthentication": "spaces.index",
    "routeIfAlreadyAuthenticated": "spaces.index"
  }

  ENV.emblemOptions = {
    "quiet": true
  }

  ENV.totem = {
    "ajax_timeout": 25000,
    "session_timeout": {
        "time": 30,
        "warning_time": 2,
        "warning_decrement_by": 1,
        "warning_message": "Your session is about to timeout!"
    },
    "simple_auth": {
        "login_route": "users.sign_in",
        "validate_user_url": "api/thinkspace/common/users/validate",
        "switch_user_whitelist_regexps": [
            "\\/spaces\\/\\\\d+",
            "\\/casespace\\/cases\\/\\\\d+"
        ]
    },
    "logger": {
        "log_level": "none",
        "log_trace": false
    },
    "messages": {
        "suppress_all": true,
        "loading_template": "totem_message_outlet/loading",
        "i18n_path_prefix": "casespace.api.success."
    },
    "stylized_platform_name": "OpenTBL",
    "grid": {
        "classes": {
            "columns": "ts-grid_columns",
            "sticky": "ts-grid_sticky"
        }
    },
    "pub_sub": {
        "namespace": "thinkspace"
    },
    "roles_map": {
        "read": "Student",
        "update": "Teaching Assistant",
        "owner": "Instructor"
    }
  }

  // Use the node 'process' environment variables (defaults values can be used in a local install).
  var app_api_host                    = process.env['APP_API_HOST']              || 'http://0.0.0.0:3000';
  var app_asset_path                  = process.env['APP_ASSET_PATH']            || 'http://0.0.0.0:4200/assets';
  var app_pub_sub_socketio_url        = process.env['APP_PUBSUB_SIO_URL']        || 'http://0.0.0.0:5555';
  var app_pub_sub_socketio_client_cdn = process.env['APP_PUBSUB_SIO_CLIENT_CDN'] || 'https://cdnjs.cloudflare.com/ajax/libs/socket.io/1.4.5/socket.io.min.js';
  var app_totem_uploader              = process.env['APP_TOTEM_UPLOADER']        || 'false';
  var app_deploy_target               = process.env['APP_DEPLOY_TARGET'];

  ENV.totem.api_host                    = app_api_host;
  ENV.totem.asset_path                  = app_asset_path;
  ENV.totem.pub_sub.socketio_url        = app_pub_sub_socketio_url;
  ENV.totem.pub_sub.socketio_client_cdn = app_pub_sub_socketio_client_cdn;
  ENV.totem.uploader                    = {s3: (app_totem_uploader == 'true')};

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER             = true;
    // ENV.APP.LOG_ACTIVE_GENERATION    = true;
    // ENV.APP.LOG_TRANSITIONS          = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS         = true;

    ENV.contentSecurityPolicy = {
      "default-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "script-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "font-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "connect-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "img-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "style-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "media-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:"
    }

  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType              = 'none';
    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS      = false;
    ENV.APP.rootElement           = '#ember-testing';
  }

  if (environment === 'production') {
    if (app_deploy_target  === 'production') {
    }
    if (app_deploy_target === 'staging') {
    }
  }

  return ENV;
};
