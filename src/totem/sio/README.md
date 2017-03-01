## totem-socketio-server

> **IMPORTANT: Once the packages are installed, they are 'not' linked to the repos.  Any changes to the 'installed' packages
need to be copied back into the repo.**

> To receive published messages outside of socket.io (e.g. from a rails server) a **[redis](#redis)** server is required.

> NOTE: The below assumes using a directory named ***socketio*** as the **node-root** directory.  However, any directory name can be used to contain
the totem-socketio-server.

### 1. Create *node-root* directory and install totem-socketio-server

```
mkdir socketio
cd socketio
npm install relative-path-to-totem-socketio-server-repo-directory

example: npm install ../../sio-repos/totem-socketio-server
```

### 2. Install platform(s)

```
npm install relative-path-to-platform-repo-directory

example: npm install ../../sio-repos/thinkspace-socketio-server
```

### 3. Edit '*node-root/app.js*' and add platform(s)


```javascript
var server = require('totem-socketio-server').create_server();

// require the platform package and pass in the socket.io server instance
// to its create method:
// require('platform-package-name').create(server)

example: require('thinkspace-socketio-server').create(server)
```

### 4. Review the environment values to ensure they match your development environment

#### Ember

* *totem-socket-server* configuration related values in the ember-cli **environment.js**
  - totem.pub_sub.namespace
  - totem.pub_sub.socketio_url (must match *node_env* variables SIO_APP_HOST & SIO_APP_PORT)
  - totem.pub_sub.socketio_client_cdn

##### environment.js

```
ENV.totem = {
  ...
  "pub_sub": {
      "namespace": "thinkspace"
  },
  ...
}

if (environment === 'development') {
  ...
  ENV.totem.pub_sub.socketio_url        = 'http://localhost:4444';
  ENV.totem.pub_sub.socketio_client_cdn = 'https://cdnjs.cloudflare.com/ajax/libs/socket.io/1.4.5/socket.io.min.js';
  ...
}
```

#### Node

##### node_env

```
export NODE_ENV=development
export SIO_APP_PORT=4444
export SIO_APP_HOST=localhost
export SIO_REDIS_PORT=6379
export SIO_REDIS_HOST=localhost
export SIO_REDIS_CONNECT_RETRY_ATTEMPTS=5
export SIO_REDIS_CONNECT_RETRY_DELAY_SECONDS=10
export SIO_DEBUGGING=true
# Example for thinkspace:
export SIO_THINKSPACE_AUTHENTICATE_URL=http://localhost:3000/api/thinkspace/pub_sub/authenticate/authenticate
export SIO_THINKSPACE_AUTHENTICATE_TIMEOUT=3000
export SIO_THINKSPACE_AUTHORIZE_URL=http://localhost:3000/api/thinkspace/pub_sub/authorize/authorize
export SIO_THINKSPACE_AUTHORIZE_TIMEOUT=3000
```

### 5. Start the socket.io server
  * cd socketio
  * source node_env  (exports the environment variables in the 'current' terminal)
  * node app.js

---

## Redis

#### Install local redis for development in *ubuntu*
* sudo apt-get install redis-server

##### If get 'network disconnected' after installing redis and restarting ubuntu, can remove the auto startup and start manually
* sudo update-rc.d -f redis-server remove
* restart unbuntu
* redis-server

##### Redis-cli debug commands
* redis-cli
  - client list  (connected clients e.g. socket.io server)
  - pubsub channels *
  - monitor  (shows connections, published messages, etc. as they happen)
  - exit     (exit redis-cli; to exit monitor: ctrl-C)

---

## Platforms

* The platform constructor is passed a single argument, the 'totem-socketio-server' instance.
* The platform constructor should set a 'server' property e.g. 'constructor: (@server) ->'.
* Most modules assume the platform module has the properties
  - nsio
  - namespace
  - util
* Some modules assume the platform module has the properties
  - request
  - messages
  - auth
