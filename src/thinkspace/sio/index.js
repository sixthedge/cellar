var thinkspace_socketio_server = require('thinkspace-socketio-server/lib/thinkspace');
exports.create = function (server) {return new thinkspace_socketio_server(server);}
