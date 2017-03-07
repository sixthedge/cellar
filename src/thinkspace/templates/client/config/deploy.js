/* jshint node: true */

module.exports = function(deployTarget) {
  var ENV = {
    build: {}
    // include other plugin configuration that applies to all deploy targets here
  };

  if (deployTarget === 'development') {
    ENV.build.environment = 'development';
    // configure other plugins for development deploy target here
  }

  if (deployTarget === 'staging') {
    ENV.build.environment = 'production';
    ENV.redis = {
      url: 'STAGING-REDIS-URL'
    }
    ENV.s3 = {
      accessKeyId:     'STAGING-AWS-INFO',
      secretAccessKey: 'STAGING-AWS-INFO',
      bucket:          'STAGING-AWS-INFO',
      region:          'STAGING-AWS-INFO'
    }
    // configure other plugins for staging deploy target here
  }

  if (deployTarget === 'production') {
    ENV.build.environment = 'production';
    ENV.redis = {
      url: 'PRODUCTION-REDIS-URL'
    }
    ENV.s3 = {
      accessKeyId:     'PRODUCTION-AWS-INFO',
      secretAccessKey: 'PRODUCTION-AWS-INFO',
      bucket:          'PRODUCTION-AWS-INFO',
      region:          'PRODUCTION-AWS-INFO'
    }
  }

  // Note: if you need to build some configuration asynchronously, you can return
  // a promise that resolves with the ENV object instead of returning the
  // ENV object synchronously.
  return ENV;
};
