/* jshint node: true */

module.exports = function(deployTarget) {
  var ENV = {
    build: {},
    redis: {
      url: process.env['APP_DEPLOY_REDIS_URL']
    },
    s3: {
      accessKeyId:     process.env['APP_DEPLOY_S3_ACCESS_KEY_ID'],
      secretAccessKey: process.env['APP_DEPLOY_S3_SECRET_ACCESS_KEY'],
      bucket:          process.env['APP_DEPLOY_S3_BUCKET'],
      region:          process.env['APP_DEPLOY_S3_REGION']
    },
    'revision-data': {
      scm: null
    }
  };

  if (deployTarget === 'development') {
    ENV.build.environment = 'development';
  }

  if (deployTarget === 'staging') {
    ENV.build.environment = 'production';
  }

  if (deployTarget === 'production') {
    ENV.build.environment = 'production';
  }

  // Note: if you need to build some configuration asynchronously, you can return
  // a promise that resolves with the ENV object instead of returning the
  // ENV object synchronously.
  return ENV;
};
