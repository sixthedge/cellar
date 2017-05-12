#!/bin/bash

SCRIPT=install.sh

usage() {
  echo
  cat << USAGE
    Usage:
      ./$SCRIPT --package package-dir --install install-dir [--platform platform-name] [--cellar cellar-dir] [--attic attic-dir] [--build build-type] [--symlink-ability] [--totem]

    Required arguments:
      -p, --package  package directory (must end in /api, /client, /sio or /totem-oauth e.g. opentbl/api)
      -i, --install  destination directory for local install

    Package directory value:
      > if absolute directory  then use as-is
        else if --attic blank? then "{cellar-dir}/packages/package-dir" else "{attic-dir}/packages/package-dir"
      > Need to use an absolute directory if the above rules do not work e.g. /my/path/to/packages/package-name/api

    Optional arguments:
      -h, --help            show this help message and exit
      -n, --platform        platform-name (use if the package-name is not the platform-name e.g. for an opentbl package use --platform thinkspace)
      -b, --build           build type [api|client|sio|totem-oauth] (usually not needed and can use the default)
      -c, --cellar          public platform directory
      -a, --attic           private platform directory
      -s, --symlink-ability symlink the api config/totem/ability_files directory to the package
      -t, --totem           copy private (attic) totem directory
USAGE
echo
}

BUILD_TYPE_HELP="Did the package have sub-directory e.g. 'package-name/api'?."

is_api()    { if [ "$BUILD_TYPE" = "api" ];         then return 0; else return 1; fi }
is_client() { if [ "$BUILD_TYPE" = "client" ];      then return 0; else return 1; fi }
is_sio()    { if [ "$BUILD_TYPE" = "sio" ];         then return 0; else return 1; fi }
is_oauth()  { if [ "$BUILD_TYPE" = "totem-oauth" ]; then return 0; else return 1; fi }

remind()  {       tput setaf 2; tput bold; echo " $@"; tput sgr0; }
info()    { echo; tput setaf 6; tput bold; echo " $@"; tput sgr0; echo; }
debug()   {       tput setaf 6; echo " $@"; tput sgr0; }
warning() { echo; tput setaf 3; tput bold; echo " [WARNING] $@"; tput sgr0; echo; }
error()   { echo; tput setaf 1; tput bold; echo " [ERROR] $@"; tput sgr0; print_vars; usage; echo; exit 1; }

is_blank()   { if [ "$1" = "" ];     then return 0; else return 1; fi }
is_present() { if is_blank $1;       then return 1; else return 0; fi }
is_equal()   { if [ "$1" = "$2" ];   then return 0; else return 1; fi }
is_true()    { if [ "$1" = "true" ]; then return 0; else return 1; fi }
is_dot()     { if [ "$1" = "." ] || [ "$1" = ".." ];    then return 0; else return 1; fi }

is_file()    { if [ -f "$1" ]; then return 0; else return 1; fi }
is_dir()     { if [ -d "$1" ]; then return 0; else return 1; fi }
is_symlink() { if [ -L "$1" ]; then return 0; else return 1; fi }
is_relative_dir() { if [[ "$1" =~ ^\. ]]; then return 0; else return 1; fi }
is_absolute_dir() { if [[ "$1" =~ ^\/ ]]; then return 0; else return 1; fi }

is_rails()       { if is_file "$PACKAGE/Gemfile"; then return 0; else return 1; fi }
is_ember_cli()   { if is_file "$PACKAGE/ember-cli-build.js"; then return 0; else return 1; fi }
is_sio_server()  { if is_file "$PACKAGE/package.json"; then return 0; else return 1; fi }

is_symlink_ability() { if is_true $SYMLINK_ABILITY; then return 0; else return 1; fi }

# ### Raise error if condition - REMINDER - put the first value in quotes.
not_present() { if is_blank $1; then error $2; fi }
not_dir()     { if is_blank $1; then error $2; fi; if ! is_dir $1; then error $2; fi }
not_dir_or_blank() { if is_present $1; then not_dir "$@"; fi }

print_vars() {
  echo
  debug "-----local/$SCRIPT-----"
  debug "Build type                   : $BUILD_TYPE"
  debug "Install directory            : $INSTALL"
  debug "Package directory (build)    : $PACKAGE"
  if ! is_equal $PACKAGE $ORIGINAL_PACKAGE; then debug "Package directory (original) : $ORIGINAL_PACKAGE"; fi
  debug "Platform name                : $PF_NAME"
  debug "Cellar platform directory    : $CELLAR_PF"
  debug "Cellar totem directory       : $CELLAR_TM"
  if is_present $ATTIC_PF; then debug "Attic platform directory     : $ATTIC_PF"; fi
  if is_present $ATTIC_TM; then debug "Attic totem directory        : $ATTIC_TM"; fi
  echo
}

PWD_DIR=$(pwd -P)

# ### Defaults.

TMP_DIR=/tmp
ATTIC_TOTEM=false
CELLAR=.. # for public directory

# ### Set variables from arguments.

OPTS=$(getopt -o hp:i:n:a:b:c:st --long help,package:,install:,platform:,attic:,build:,cellar:,symlink-ability,totem -n build -- "$@")
if [ $? != 0 ]; then error "Error in command line arguments: $@"; usage; fi
set -e
eval set -- "$OPTS"

while true; do
  # echo "1:$1 2:$2"
  case "$1" in
    -h | --help )           usage; exit; ;;
    -i | --install )        INSTALL="$2";           shift 2 ;;
    -p | --package )        PACKAGE="$2";           shift 2 ;;
    -a | --attic )          ATTIC="$2";             shift 2 ;;
    -c | --cellar )         CELLAR="$2";            shift 2 ;;
    -n | --platform )       PF_NAME="$2";           shift 2 ;;
    -b | --build )          BUILD_TYPE="$2";        shift 2 ;;
    -s | --symlink-ability) SYMLINK_ABILITY="true"; shift ;;
    -t | --totem )          ATTIC_TOTEM="true";     shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# ### Validate required arguments.

not_present "$PACKAGE" "Package directory is blank."
not_present "$INSTALL" "Install directory is blank."

ORIGINAL_PACKAGE="$PACKAGE"

# ### Default some optional arguments when not specified.

if is_blank $PF_NAME; then
  PF_NAME=$(dirname $PACKAGE)  # strip /api, /client, /sio, etc.
  PF_NAME=$(basename $PF_NAME)
  if is_dot $PF_NAME; then PF_NAME=""; fi  # blank no sub-folder specified e.g. opentbl (s/b opentbl/api)
fi

if ! is_absolute_dir $PACKAGE; then
  if is_blank $ATTIC; then PACKAGE=$CELLAR/packages/$PACKAGE; else PACKAGE=$ATTIC/packages/$PACKAGE; fi
fi

if is_blank $BUILD_TYPE; then
  BUILD_TYPE=$(basename $PACKAGE)  # set the build type e.g. api, client, sio
  if is_dot $BUILD_TYPE; then BUILD_TYPE=""; fi
fi

if is_present $CELLAR; then
  CELLAR_PF=$CELLAR/src/$PF_NAME/$BUILD_TYPE
  CELLAR_TM=$CELLAR/src/totem/$BUILD_TYPE
fi

if is_present $ATTIC; then
  ATTIC_PF=$ATTIC/src/$PF_NAME/$BUILD_TYPE
  if is_true $ATTIC_TOTEM; then ATTIC_TM=$ATTIC/src/totem/$BUILD_TYPE; fi
fi

if is_oauth; then
  CELLAR_PF=$PACKAGE
  CELLAR_TM=""
  if is_blank $PF_NAME; then PF_NAME=$BUILD_TYPE; fi
fi

# ### Validation.

not_present "$PF_NAME"    "Platform name is blank."
not_present "$CELLAR"     "Cellar directory is blank."
not_present "$BUILD_TYPE" "Build type is blank.  $BUILD_TYPE_HELP"

if ! { is_api || is_client || is_sio || is_oauth; }; then error "Package build must be for api, client, sio or totem-oauth not ($BUILD_TYPE).  $BUILD_TYPE_HELP"; fi

not_dir          "$PACKAGE"   "Package source ($PACKAGE) is not a directory."
not_dir          "$CELLAR_PF" "Cellar $PF_NAME source ($CELLAR_PF) is not a directory.  Do you need to add a platform name?"
not_dir_or_blank "$CELLAR_TM" "Cellar totem source ($CELLAR_TM) is not a directory."
not_dir_or_blank "$ATTIC_PF"  "Attic $PF_NAME source ($ATTIC_PF) is not a directory.  Do you need to add a platform name?"
not_dir_or_blank "$ATTIC_TM"  "Attic totem source ($ATTIC_TM) is not a directory."

create_install_dir() {
  if is_dir $INSTALL; then
    warning "Install directory ($INSTALL) already exists.  Only new and common files are installed.  Other files still remain."
  else
    mkdir -p $INSTALL
  fi
}

create_node_modules_dir() {
  NODE_MODULES=$INSTALL/node_modules
  if ! is_dir $NODE_MODULES; then mkdir -p $NODE_MODULES; fi
}

copy_dir_if_present() {
  if is_present $1 && is_present $2; then
    not_dir "$1" "Copy source directory ($1) is not a directory."
    not_dir "$2" "Copy destination directory ($2) is not a directory."
    cp -r $1 $2
  fi
 }

copy_dir_content_if_present() {
  if is_present $1 && is_present $2; then
    not_dir "$1" "Copy source directory ($1) is not a directory."
    not_dir "$2" "Copy destination directory ($2) is not a directory."
    cp -r --remove-destination $1/. $2
  fi
 }

copy_file_if_present() {
  if is_present $1 && is_file $1; then
    not_dir "$2" "Copy destination directory ($2) is not a directory."
    cp $1 $2
  fi
 }

copy_package() { copy_dir_content_if_present $PACKAGE $INSTALL; }

set_absolute_src_paths() {
  # ###  Add in the order to search for packages (e.g. attic dirs first when exist).
  if is_present $ATTIC_PF;  then ABSOLUTE_SRC_PATHS+=" --src $PWD_DIR/$ATTIC_PF";  fi
  if is_present $ATTIC_TM;  then ABSOLUTE_SRC_PATHS+=" --src $PWD_DIR/$ATTIC_TM";  fi
  if is_present $CELLAR_PF; then ABSOLUTE_SRC_PATHS+=" --src $PWD_DIR/$CELLAR_PF"; fi
  if is_present $CELLAR_TM; then ABSOLUTE_SRC_PATHS+=" --src $PWD_DIR/$CELLAR_TM"; fi
}

delete_dir() {
  local target_dir="$1"
  if is_symlink $target_dir; then `rm $target_dir`; fi
  if is_file    $target_dir; then `rm $target_dir`; fi
  if is_dir     $target_dir; then `rm -r $target_dir`; fi
}

create_symlink() {
  local target_dir="$1"
  local src_dir="$2"
  not_present $target_dir "Symlink target directory is blank."
  not_present $src_dir    "Symlink source directory is blank."
  not_dir $src_dir        "Symlink source directory ($src_dir) is not a directory."
  if is_dir $target_dir; then error "Symlink target directory ($target_dir) already exists.  Delete and run again."; fi
  info "Symlink ($src_dir) to ($target_dir)."
  `ln -s "$src_dir" "$target_dir"`
}

print_vars

if is_api; then
  if ! is_rails; then error "Package source directory ($PACKAGE) is not a Rails application."; fi
  create_install_dir
  info "Copying API package source ($PACKAGE) to ($INSTALL)."
  AB_FILES=$INSTALL/config/totem/ability_files
  if is_relative_dir $AB_FILES; then AB_FILES=$PWD_DIR/$AB_FILES; fi
  delete_dir $AB_FILES  # delete incase is a symlink so cp will work
  copy_package
  if is_symlink_ability; then
    SRC_AB_FILES=$PACKAGE/config/totem/ability_files
    if is_relative_dir $SRC_AB_FILES; then SRC_AB_FILES=$PWD_DIR/$SRC_AB_FILES; fi
    delete_dir $AB_FILES
    create_symlink $AB_FILES $SRC_AB_FILES
  fi
  remind "Reminder: need to run 'bundle install' in ($INSTALL) and seed the database."
fi

if is_oauth; then
  if ! is_rails; then error "Package source directory ($PACKAGE) is not a Rails application."; fi
  create_install_dir
  BUILD_TYPE=api
  info "Copying totem-oauth source ($PACKAGE) to ($INSTALL)."
  copy_package
  remind "Reminder: need to run 'bundle install' in ($INSTALL) and seed the database."
fi

if is_client; then
  if ! is_ember_cli; then error "Package source directory ($PACKAGE) is not a Ember-cli application."; fi
  create_install_dir
  info "Copying client package source ($PACKAGE) to ($INSTALL)."
  copy_package
  create_node_modules_dir
  set_absolute_src_paths
  info "Calling 'client-link.sh to link local packages in ($INSTALL)."
  if is_absolute_dir $INSTALL; then EMBER_CLI=$INSTALL; else EMBER_CLI=$PWD_DIR/$INSTALL; fi
  ./client-link.sh --platform $PF_NAME --dir $EMBER_CLI --unlink --link ${ABSOLUTE_SRC_PATHS[@]}
  cd $INSTALL
  info "Installing bower packages in ($INSTALL)."
  bower install
  info "Installing npm packages in ($INSTALL)."
  npm install
fi

if is_sio; then
  if ! is_sio_server; then error "Package source directory ($PACKAGE) is not a Socket.io server."; fi
  create_install_dir
  info "Copying sio package source ($PACKAGE) to ($INSTALL)."
  copy_package
  create_node_modules_dir
  PF_SIO=$NODE_MODULES/$PF_NAME-socketio-server
  TM_SIO=$NODE_MODULES/totem-socketio-server
  if ! is_dir $PF_SIO; then mkdir $PF_SIO; fi
  if ! is_dir $TM_SIO; then mkdir $TM_SIO; fi
  info "Copying sio platform server source ($CELLAR_PF) to ($PF_SIO)."
  copy_dir_content_if_present $CELLAR_PF $PF_SIO
  copy_dir_content_if_present $ATTIC_PF  $PF_SIO
  info "Copying sio totem server source ($CELLAR_TM) to ($TM_SIO)."
  copy_dir_content_if_present $CELLAR_TM $TM_SIO
  copy_dir_content_if_present $ATTIC_TM  $TM_SIO
  info "Install npm packages in ($INSTALL)."
  cd $INSTALL
  npm install
  # ### Reminders.
  remind "To start the local socketio server:"
  remind "    cd $INSTALL"
  remind "    source node_env"
  remind "    node app.js"
  echo
  remind "    # reminder: review the 'node_env' values to ensure match your environment"
  remind "    # reminder: the code is copied so changes to the cellar source will not be reflected in the node packages"
fi

echo
