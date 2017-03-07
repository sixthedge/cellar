  var deploy_target = process.env['DEPLOY_TARGET'];

  if (deploy_target === 'staging') {
    APP_OPTIONS.fingerprint = {
      "prepend":    "STAGING-PREPEND",
      "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
    }
  }

  if (deploy_target === 'production') {
    APP_OPTIONS.fingerprint = {
      "prepend":    "PRODUCTION-PREPEND",
      "extensions": ['js', 'css', 'png', 'jpg', 'gif', 'map', 'svg']
    }
  }

  APP_OPTIONS.sassOptions = {
    "includePaths": [
        "node_modules/totem-assets/styles",
        "node_modules/thinkspace-assets/styles",
        "bower_components/foundation-sites/scss",
    ],
    "imagePath": "/assets/images"
  }
