var server = require('totem-socketio-server').create_server();

require('thinkspace-socketio-server').create(server)

process.on('SIGINT', () => {
  console.log('');
  console.log('--exiting totem-socketio-server--');
  process.exit(0);
});
