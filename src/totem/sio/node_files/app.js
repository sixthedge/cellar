var server = require('totem-socketio-server').create_server();

// require the platform package and pass in the socket.io server instance
// to its create method:
// require('platform-package-name').create(server)

// require('thinkspace-socketio-server').create(server)

process.on('SIGINT', () => {
  console.log('');
  console.log('--exiting totem-socketio-server--');
  process.exit(0);
});
