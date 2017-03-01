require('coffee-script/register');
var totem_socketio_server = require('totem-socketio-server/lib/server');

exports.create_server = function () {return new totem_socketio_server();}
