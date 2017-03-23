  var ENV = {
    "modulePrefix": "<%=module_prefix%>",
    "rootURL":      "<%=rootURL%>",
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
  deploy_target              = process.env['DEPLOY_TARGET']

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
        "namespace": "<%=pubsub.namespace%>"
    },
    "roles_map": {
        "read": "Student",
        "update": "Teaching Assistant",
        "owner": "Instructor"
    }
  }

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER             = true;
    // ENV.APP.LOG_ACTIVE_GENERATION    = true;
    // ENV.APP.LOG_TRANSITIONS          = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS         = true;

    ENV.totem.api_host                    = '<%=dev.api_host%>';
    ENV.totem.asset_path                  = '<%=dev.asset_path%>';
    ENV.totem.pub_sub.socketio_url        = '<%=dev.sio_url%>';
    ENV.totem.pub_sub.socketio_client_cdn = '<%=dev.sio_cdn%>';
    ENV.totem.uploader                    = {s3: false};
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
    ENV.totem.uploader = {s3: true};
    if (deploy_target  === 'production') {
      ENV.totem.api_host                    = 'PRODUCTION-API-HOST';
      ENV.totem.asset_path                  = 'PRODUCTION-ASSET-PATH';
      ENV.totem.pub_sub.socketio_url        = 'PRODUCTION-SIO-URL';
      ENV.totem.pub_sub.socketio_client_cdn = 'PRODUCTION-SIO-CDN';
    }
    if (deploy_target === 'staging') {
      ENV.totem.api_host                    = 'STAGING-API-HOST';
      ENV.totem.asset_path                  = 'STAGING-ASSET-PATH';
      ENV.totem.pub_sub.socketio_url        = 'STAGING-SIO-URL';
      ENV.totem.pub_sub.socketio_client_cdn = 'STAGING-SIO-CDN';
    }
  }
