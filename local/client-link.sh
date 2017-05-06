#!/bin/bash

SCRIPT=client-link.sh

usage() {
  echo
  cat << USAGE
    Usage:
      ./$SCRIPT -n platform-name --src source-dir [--src source-dir] [-d ember-cli-dir] [--link] [--unlink]

    Arguments:
      -n, --platform       platform name
      -s, --src            source directory to look for the packages
                           - multiple --src arguments can be used and will be searched in argument order
      -d, --dir            ember-cli application directory - default is current directory
      -l, --link           link packages - --link is the default when neither --link or --unlink are used
                           - link does an 'unlink' before the link
      -u, --unlink         unlink packages - use without --link to only unlink the packages

    Packages are extracted from the package.json that match the platform-name or totem.

USAGE
echo
}

PWD_DIR=$(pwd -P)
EMBER_CLI=$PWD_DIR  # default

info()    { echo; tput setaf 6; tput bold; echo " $@"; tput sgr0; echo; }
debug()   {       tput setaf 6; echo " $@"; tput sgr0; }
warning() {       tput setaf 3; tput bold; echo " [WARNING] $@"; tput sgr0; }
error()   { echo; tput setaf 1; tput bold; echo " [ERROR] $@"; tput sgr0; print_vars; usage; echo; exit 1; }

is_file()    { if [ -f "$1" ]; then return 0; else return 1; fi }
is_dir()     { if [ -d "$1" ]; then return 0; else return 1; fi }
is_symlink() { if [ -L "$1" ]; then return 0; else return 1; fi }
is_blank()   { if [ "$1" = "" ]; then return 0; else return 1; fi }
is_present() { if is_blank $1;   then return 1; else return 0; fi }
is_true()    { if [ "$1" = "true" ]; then return 0; else return 1; fi }
is_absolute_dir() { if [[ "$1" =~ ^\/ ]];   then return 0; else return 1; fi }

is_ember_cli()   { if is_file "$NODE_MODULES/../ember-cli-build.js"; then return 0; else return 1; fi }

not_present() { if is_blank $1; then error $2; fi }
not_dir()     { if is_blank $1; then error $2; fi; if ! is_dir $1; then error $2; fi }

do_link()     { if is_true $LINK;    then return 0; else return 1; fi }
do_unlink()   { if is_true $UNLINK;  then return 0; else return 1; fi }
do_volumes()  { if is_true $VOLUMES; then return 0; else return 1; fi }

print_vars() {
  echo
  debug "-----$SCRIPT-----"
  debug "Platform name          : $PF_NAME"
  debug "Ember-cli directory    : $EMBER_CLI"
  debug "Node modules directory : $NODE_MODULES"
  debug "Link                   : $LINK"
  debug "Unlink                 : $UNLINK"
  debug "Source directories     : "
  for s in "${SOURCES[@]}"; do debug "   - $s"; done
  echo
}

OPTS=$(getopt -o hn:s:d:lu --long help,platform:,src:,dir:,link,unlink -n client-link -- "$@")
if [ $? != 0 ]; then error "Error in command line arguments: $@"; usage; fi
set -e
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h | --help )       usage; exit; ;;
    -n | --platform )   PF_NAME="$2";     shift 2 ;;
    -d | --dir )        EMBER_CLI=("$2"); shift 2 ;;
    -s | --src )        SOURCES+=("$2");  shift 2 ;;
    -l | --link )       LINK="true";      shift ;;
    -u | --unlink )     UNLINK="true";    shift ;;
    -v | --volumes )    VOLUMES="true";   shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if ! { do_link || do_unlink || do_volumes; }; then LINK="true"; fi # default to link

not_present "$PF_NAME"   "Platform name is blank."
not_present "$EMBER_CLI" "Ember-cli directory is blank."
not_present "$SOURCES"   "Packcage sources are blank."

not_dir "$EMBER_CLI"    "Ember-cli directory ($EMBER_CLI) is not a directory."
NODE_MODULES=$EMBER_CLI/node_modules

not_dir "$NODE_MODULES" "Node modules directory ($NODE_MODULES) is not a directory."

if ! is_ember_cli; then error "Ember-cli directory ($EMBER_CLI) is not an ember-cli application."; fi

set_packages() { PACKAGES=`cat $NODE_MODULES/../package.json | grep -o \"$1.*: | tr -d '":' | tr '\n' ' '`; }

set_src_dir() {
  SRC_DIR=""
  local pkg=$1
  for src in "${SOURCES[@]}"
  do
    if is_present $src; then
      if is_absolute_dir $src; then lsrc="$src"; else lsrc="$PWD_DIR/$src"; fi
      local dir=$lsrc/$pkg
      if is_dir $dir; then
        SRC_DIR="$lsrc"
        break
      fi
    fi
  done
}

unlink_msg() { tput setaf 1; echo " $@"; tput sgr0; }
link_msg()   { tput setaf 2; echo " $@"; tput sgr0; }

unlink() {
  local unlink_pkg=$1
  if is_symlink $unlink_pkg; then
    unlink_msg " Unlink $unlink_pkg"
    `rm $unlink_pkg`
  fi
}

link() {
  local link_src=$1
  local link_pkg=$2
  if ! do_unlink; then unlink $link_pkg; fi  # if --unlink then already done
  if is_dir $link_src; then
    if is_dir $link_pkg && ! { is_symlink $link_pkg; } then
      warning "'$link_pkg' is not a symlink but a real directory.  Skipping link."
    else
      link_msg " Link   $link_pkg to $link_src"
      `ln -s $link_src $link_pkg`
    fi
  else
    warning "No symlink created for ($link_pkg) - source directory ($link_src) does not exist)."
  fi
}

process() {
  set_packages $1
  local pkgs=($PACKAGES)
  for pkg in "${pkgs[@]}"
  do
    set_src_dir $pkg
    local src=$SRC_DIR
    if is_blank $src; then
      warning "Missing source directory for package ($pkg).  Skipping."
    else
      if do_unlink;  then unlink $pkg; fi
      if do_link;    then link $src/$pkg $pkg; fi
      if do_volumes; then add_volume $pkg; fi
    fi
  done
}

# ### Process packages.
print_vars
cd $NODE_MODULES
process $PF_NAME
process totem
