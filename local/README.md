# Cellar Based Local Install Examples

> #### :warning: Be sure the --install path matches your environment.

### API

**cd my/path/to/attic/cellar/local**

```
# totem-oauth
./install.sh --package ../../totem-oauth --install ../../apps-rails/totem-oauth

# opentbl (remove the --symlink-ability if want the ability files copied into the rails app)
./install.sh --package opentbl/api --install ../../apps-rails/opentbl --platform thinkspace --symlink-ability
```

### Client

**cd my/path/to/attic/cellar/local**

```
# opentbl
./install.sh --package opentbl/client --install ../../apps-ember/opentbl --platform thinkspace

```

### Socket.io

**cd my/path/to/attic/cellar/local**

```
# opentbl
./install.sh --package opentbl/sio --install ../../apps-sio/opentbl --platform thinkspace

```
