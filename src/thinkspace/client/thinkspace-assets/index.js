/* jshint node: true */
'use strict';

module.exports = {
  name: 'thinkspace-assets',
  contentFor: function(type, config, content) {
    if (type === 'head') {
      var add = [];
      
      add.push('<link href="https://fonts.googleapis.com/css?family=Noto+Sans:400,400i,700" rel="stylesheet">');
      if (config.environment === 'production') {
        add.push('<link rel="icon" href="https://s3.amazonaws.com/thinkspace-prod/assets/images/favicon.ico">');
        add.push('<script src="//js.pusher.com/3.0/pusher.min.js"></script>');
      }
      return add.join('\n');
    }
  }
};
