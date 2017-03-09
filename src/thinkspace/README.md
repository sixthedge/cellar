# Thinkspace Platform
The Thinkspace platform contains the source base and build scripts for the Rails and Ember applications. Thinkspace is required to be used in conjunction with the [Totem Platform](https://github.com/sixthedge/cellar/tree/master/src/totem).

## Structure
- `ability`
  - Authorization rules for the rails endpoints
- `api`       
  - All Rails engines used for the API back-end
- `client`    
  - All Ember engines used for the front-end
- `packages`  
  - Project configuration YAML files used to build
- `sio`       
  - NPM module and javascript code for Web Sockets
- `templates` 
  - File templates used to copy into during the build