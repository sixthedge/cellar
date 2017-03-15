# Install
  * docker
  * docker-compose

# Create Images

```
cd my/path/to/cellar/docker/dev
./build.sh

```

# API Docker Compose

```
UP:
cd my/path/to/cellar/docker/dev/compose/api
docker-compose up --remove-orphans

DOWN:
cd my/path/to/cellar/docker/dev/compose/api
docker-compose down

```

# Client Docker Compose

```
UP:
cd my/path/to/cellar/docker/dev/compose/client
docker-compose up --remove-orphans

DOWN:
cd my/path/to/cellar/docker/dev/compose/client
docker-compose down

```

# Browser
  * **ember-cli** ip address is *172.16.66.66*
```
e.g.
http://172.16.66.66:4200/users/sign_in
```

# API

* **Host dependent** paths that must match your environment.
  * *rails.yml* mounts the platform and totem source at:
    * **/src/platform**
    * **/src/totem**
    * all file references should be relative to these directories
    * the *docker-compose* .env file should point to the actual paths

#### docker/dev/compose/api/.env (absolute or relative paths)
  * *RAILS_PLATFORM_SRC* : path to platform root (e.g. not the /api directory)
  * *RAILS_TOTEM_SRC* : path to totem root (e.g. not the /api directory)
  * *RAILS_GEMFILE_SRC* : path to gemfiles relative to RAILS_PLATFORM_SRC and RAILS_TOTEM_SRC
  * *RAILS_CONFIG_SRC* : path to Rails.root/config files
  * *SIO_PLATFORM_SRC* : path to platform socketio server package
  * *SIO_TOTEM_SRC* : path to totem socketio server package
  * *SIO_NODE_SRC* : path to *app.js*


# Client
  * **Host dependent** paths that must match your environment.
    * *ember.yml* mounts the platform and totem source at:
      * **/home/app/orchid/node_modules**

#### docker/dev/compose/client/.env (absolute or relative paths)
  * *EMBER_PLATFORM_SRC* : path to platform ember packages (e.g. .../client)
  * *EMBER_TOTEM_SRC* : path to totem ember packages (e.g. .../client)
  * *EMBER_SRC* : path to platform ember files
    * packages.json
    * ember-cli-bulid.js
    * app/app.js
    * app/index.html
    * app/styles/app.scss
    * config/environment.js
    * config/deploy.js

# *docker/dev* Configuration Files

#### /rails
  1. **Gemfile** and **Gemfile.lock**
    * *common* and *thinkspace (non-engine)* gems

#### /sio
  1. **app/package.json**
    * socket.io base package dependencies (s/b same as *totem/sio/node_files/package.json*)
      * socket.io
      * coffee-script
      * redis
      * request

#### /ember-cli/base
  1. **Dockerfile** installs
    * ember-cli v2.10.1
    * bower v1.8.0

#### /ember-cli/base-app
  1. **Dockerfile** installs
    * ember-cli base packages
      * bower.json
      * ember-data
      * ember-engines
      * ember-coffeescript
      * ember-changeset
      * etc.

#### /postgres
  1. **init/00_db_create.sql**
    * define database, users, roles

---

# FWIW (command alises)

```
dstop()   { docker stop $(docker ps -a -q); }
dremove() { dstop; docker rm $(docker ps -a -q); }

di()    { clear; docker images "$@"; }
dib()   { docker build --force-rm "$@"; }
dps()   { docker ps "$@"; }
dir()   { docker run -it --rm  "$1" bash; }
dia()   { docker images --all "$@"; }
dirm()  { docker image rm "$@"; }
dirn()  { docker rmi -f $(docker images --filter "dangling=true" -q --no-trunc); }
dipr()  { docker images prune --all "$@"; }
dlogs() { docker logs "$@"; }

dnls() { clear; docker network ls; }
dnpr() { docker network prune; }
dni()  { docker network inspect "$@"; }

dc()     { docker-compose "$@"; }
dcb()    { docker-compose build --force-rm "$@"; }
dcr()    { docker-compose run --rm --no-deps "$1" bash; }
dcex()   { docker-compose exec "$1" bash; }
dclogs() { docker-compose logs "$@"; }

dcup() { clear; docker-compose up --remove-orphans "$@"; }
dcdn() { docker-compose down "$@"; }

dvls() { docker volume ls; }
dvpr() { docker volume prune; }

```
