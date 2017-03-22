# Install (>= v1.13)
  1. docker
  1. docker-compose

# Docker Builds Using /tmp
:warning: Some *build* scripts require the use of the temporary directory ***/tmp***.

*Docker* (as of v1.13) cannot copy files outside the directory containing the *Dockerfile* (for security reasons).  As a workaround, the docker and source files are copied into */tmp* for the build. For more info, see this docker [github issue](https://github.com/docker/docker/issues/2745).
For example a Dockerfile "*COPY ../my-relative-directory .*" is not allowed.

A typical case where */tmp* is used, is copying *totem* and *platform* source files to build an image.

##### *build.sh* scripts using */tmp*:
1. dev/oauth
1. prod/oauth
1. prod/rails
1. prod/sio

# Base Builds
The concept of a *base* build is to create a shared image that a child image can use as a base e.g. in a Dockerfile's *FROM my/base:0.0.0*.  They are not required.

> Note: A child image could remove functionality (e.g. an init script) as will as add or modify functionality.

Typically they would be used:
1. To ensure child images always start with the same base.
2. To encapsulate process intensive actions so they do not have to be repeated.  For example bundling Rails gems, installing node/ember-cli packages, etc.

What should be in the final *child* image varies.  Basically it should contain any environment specific values and/or functionality.

# Environment Variables for docker and docker-compose

### ENV vs .env vs env_file: vs environment:

Docker-compose uses the values in *.env* when creating containers (a .env file in same directory as the docker-compose yml file).
These values can be used in the *yml* file as string substitutions
or as docker-compose CLI values (e.g. COMPOSE_FILE, COMPOSE_PROJECT_NAME).
They are **not** set in the container's env.

The *docker-compose yml* has two ways to set environment variables in the **container**.
1. env_file: filename (relative or absolute path) (text file with key=value)
2. environment: {key: value, ...}
  * These *environment* values will override the *env_file* values.

**Container** environment values can also be set in a *Dockerfile*.
* ENV key value
* ENV key='value'
  * provides ability to *chain* key=value pairs with one ENV statement (e.g. in a single intermediate layer)

Dockerfile *ENV key=value* carry-forward into child images (e.g. do not need to duplicate in a child image).

#### phusion/passenger with nginx and Rails
Passenger with *nginx* sets environment variables differently.
First *nginx* deletes all environment variables.
Passenger will then set some of them (e.g. RAIL_ENV).

In order to set docker container environment variables in the Rails environment,
need to add a *nginx* configuration file with *env ENV-VAR;*. For example:

```
# /etc/nginx/main.d/app_env.conf
env APP_REDIS_URL;  # add the container's env var APP_REDIS_URL to the Rails env

# Rails
url = ENV['APP_REDIS_URL']
```

#### Init Scripts
Since init scripts are run in the container itself so any docker ENV and/or docker-compose env_file:/environment: values are available to them (unlike a passenger/rails env).

# Create Images

> Assumes have git clones of ***cellar*** and ***totem-oauth***.

> Note: *totem-oauth* must be in the **same** parent directory as *cellar*.

```
# Example:
ember20  #=> parent directory
  |- cellar
  |- totem-oauth
```

```
cd my/path/to/cellar/docker
./build-all.sh

```

# API Docker Compose

```
Dev UP:
cd my/path/to/cellar/docker/dev/compose/api
docker-compose up

Dev DOWN:
cd my/path/to/cellar/docker/dev/compose/api
docker-compose down

```

```
Prod UP:
cd my/path/to/cellar/docker/prod/compose/api
docker-compose up

Prod DOWN:
cd my/path/to/cellar/docker/prod/compose/api
docker-compose down

```

# Client Docker Compose

```
Dev UP:
cd my/path/to/cellar/docker/dev/compose/client
docker-compose up

Dev DOWN:
cd my/path/to/cellar/docker/dev/compose/client
docker-compose down

```

# Browser
  * **ember-cli** static ip address is ***172.16.66.66***
    * set in the docker/dev/compose/client/ember.yml

```
# For example:
http://172.16.66.66:4200/users/sign_in
```

# API Development vs Production

#### *dev/compose/api/rails.yml*
Both the development and production docker images use the same internal directory structure.
* A production image docker build **copies** the files into the image (using /tmp when necessary).
* A development image **mounts** the files via docker-compose *volumes*.
  * Mounting allows modified source to be reflected in the running container.

###### Volume Mounts
* totem and platform engine source:
  * **/src/platform**
  * **/src/totem**
* platform package gemfiles:
  * **/src/gemfiles**
    * Files in this directory have their content appended to the base Rails Gemfile.
    * A *bundle --local* is always performed after the Gemfile is updated.
* platform package *rails config* files:
  * **/src/rails/config**
    * Files in this directory are copied to *Rails.root/config*.
    * The files are created or will overlay the default rails files.
* platform *ability* files
  * **/src/ability**
* totem and platform package *config* files (e.g. totem.config.yml)
  *  **/src/config_files**/*filename.config.yml*


> All configuration file references should use these absolute paths.

> :warning: When mounting a ***file***, the source file must exist, otherwise docker assumes it is a directory.

#### *dev/compose/api/sio.yml*

###### Volume Mounts
* totem socket.io server source
  * **/src/totem**
* platform socket.io server source
  * **/src/platform**
* *app.js* file
  * **/src/node**

> :warning: The totem and platform socket.io server source is used by an init script to run ***npm install /src/totem*** and ***npm install /src/platform*** (e.g. source modifications are not reflected in the sio server - it must be restarted).

#### dev/compose/api/.env (absolute or relative paths)
  * *S_BASE* : path to *cellar/src* (e.g. source directory)
  * *PF_PKG* : path to *platform's* api package directory
  * *TM_PKG* : path to *totem's* api package directory


# Client

#### *dev/compose/client/ember.yml*

###### Volume Mounts

> Mounting allows modified source to be reflected in the running container and reload the ember application.

> :warning: Must do a restart if modify a file in /src/ember.

* **/src/ember** (contains files used by the *start* script)
  * **package.json** with *devDependencies*
    * *start* script will merge this package.json file with the base image's package.json.
    * The */src/ember/package.json* values take precedence in the merge but typically only the totem and platform packages are included a *devDependencies* section (since the section is a hash and are merged with the base devDependencies).
  * **ember-cli-bulid.js**
    * *start* script will copy to app-path.
* **/app-path/app**
  * app.js
  * index.html
  * styles/app.scss
* **/app-path/config**
  * environment.js
  * deploy.js
* **/app-path/node_modules**
  * totem packages
  * platform packages

#### docker/dev/compose/client/.env (absolute or relative paths)
  * *TM_SRC* : path to ember totem packages (e.g. ...cellar/src/totem/client)
  * *PF_SRC* : path to ember platform packages
  * *PF_PKG* : path to platform's packages client directory with ember-cli files
    * Mounted as the */src/ember* directory but some sub-directories are also mounted separately for *app-path/app* and *app-path/config* so *watchman* will trigger a reload if modified.
  * *APP_PATH* : path to app root (currently /home/app/orchid)
    * Used on the right-side of the volumes mount in the container.
  * *MOD_PATH* : path to app node modules (currently /home/app/orchid/node_modules)
    * Used on the right-side of the volumes mount in the container.

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
