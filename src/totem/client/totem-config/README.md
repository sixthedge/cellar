## *_config* hash keys

```
env:             [hash] - REQUIRED
engines:         [string|hash|array-of-[string|hash]]
external_routes: [string|array-of-strings]
mount:           [string|hash]
ns:              [hash]
query_params:    [hash]
services:        [string|array-of-strings]
add_services:    [string|array-of-strings]
except_services: [string|array-of-strings]
```

### *ns:* hash keys

```
ns:
  namespaces:        [hash]
  type_to_namespace: [hash]

```

### *env:* (environment)

  * The environment must include a **modulePrefix** value.

```
Engine _config:
  import env from './config/environment'
  export default {env: env}

Non-engine addon _config:
  export default {env: {modulePrefix: 'my-name'}}

```
___

### *totem-engines/engines* keys

  * engines
  * external_routes
  * services
  * add_services
  * except_services

##### Routeable (router *mounted* engines)
```
external_routes: ['spaces.show', 'cases.show']

engines: [
  'thinkspace-messages'
  'thinkspace-dock'
  'thinkspace-toolbar':  {external_routes: {home: 'spaces.index', 'users.profile'}}
]
```
  * *external_routes* is only used for a routeable engine.
  * Note: a *routeless* engine's external_routes should be included in the **engines:**
    configuration in a hash e.g. 'thinkspace-toolbar' above.

##### Routeless (template *{{mount}}* engines)
```
engines: ['thinkspace-indented-list']
```

##### Services
  * Every engine by default includes all **root-level** services e.g. app-name/services/service-name.
  * Namespaced services (e.g. engine services) are **not** included by default.
  * A *root-level* service must be part of a **non-engine addon** in the *app/services* folder.

  * To add, remove or set specific services use the *services*, *add_services* and/or *except_services* keys.
    * The *services* key will override the default services.
    * Be careful when using these keys, when the engine is mounted, the *owner* must have the services registered.
      The *owner* for a routeable engine is the **app** itself, while the *owner* for a routeless engine is the current engine.
      Therefore, as engines mount engines, the services must be registerd in each engine. Also, the providing engine and
      the consuming engine have a *services:* configuration and they must be compatible.

### *totem-config/routes* keys

  * mount

```
mount: 'users'  #=> mount('thinkspace-users', {as: 'users'})
mount: {as: 'users', path: '/myusers'}
```
  * When a *string*, the engine name is determined from the *env*.
  * Use a hash to add values such as *path*.
  * Engine is mounted at the **root** level.

### *totem-config/ns_map* keys

  * ns
```
ns:
  namespaces:
    casespace: 'thinkspace/casespace'
  type_to_namespace:
    phase: 'casespace'
```
  * Used by *totem/ns* to generate a model's full path e.g. *thinkspace/casespace/phases*.

### *totem-config/query_params* keys

  * query_params
```
query_params:
  phase: ownerable: true, authable: false
```
  * Set a model's class to indicate whether to include ownerable and authable on server requests.

### Purposes of *_config*
  1. The *app* can be static (easier creation of new app with ember-cli).
  1. The *router* can be static and defined at the totem level.
  1. Each engine's *addon/engine.coffee* can be static.
  1. Routable and routeless engine values are verified for the correct structure.
  1. New engines can be added without modifing the core application (other than the package.json and ember-cli-build.js).

### *addon/engine*
```
import config        from './config/environment'
import totem_engines from 'totem-engines/engines'
export default new totem_engines(config).get_engine()
```
