/* jshint node: true */
'use strict';

module.exports = {
  name: 'totem-pub-sub',
  isDevelopingAddon: function() {return true},  // see ember-cli issue #2451
  contentFor: function(type, config, content) {
    if (type === 'head') {
      var pubsub  = (config.totem.pub_sub || {});
      var sio_cdn = pubsub.socketio_client_cdn;
      if (!sio_cdn) {return ''}
      var src = "<script src='" + sio_cdn + "'></script>"
      return(src);
    }
  }
}
