# The Cellar
The monolithic repository that houses the code for a number of educational projects, such as:
  * **OpenTBL** - [Site](http://www.opentbl.com) - [Repo](https://github.com/sixthedge/opentbl/)

## Platforms
Inside the main `src` folder contains the platforms required for these projects. Each platform has a corresponding number of folders for building and the source code itself.

### Thinkspace
- `ability`: Ruby files used for authorization rules
- `api`: All Rails engines used for the API back-end
- `client`: All Ember packages used for the front-end
- `packages`: Project config YAML files used to build the application
- `sio`: NPM module and javascript code for Web Sockets
- `templates`: Files used to copy into an application during the build

### Totem
- `api`: All Rails engines used for the API back-end
- `client`: All Ember packages used for the front-end
- `ember`: Build time ember modification YAML files
- `packages`: Project config YAML files used to build the application
- `sio`: NPM module and javascript code for Web Sockets

## Usage
All of packages for these projects are found here though each installation may require only a subset of these packages. 

Platforms are installed through `totem-app`.  Installation instructions are on the specific repositories (e.g. [OpenTBL](https://github.com/sixthedge/opentbl/)).
