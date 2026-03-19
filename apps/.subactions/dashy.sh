#!/usr/bin/with-contenv bash
# shellcheck shell=bash
FOLDER="/opt/appdata"
CONF="${FOLDER}/dashy/conf.yml"
appfolder="/opt/homelabarr-cli/apps"
FILE=".subactions/dashy.j2"

appstartup() {
   if [[ -f $CONF ]]; then
      $(command -v chown) -cR 1000:1000 $FOLDER/dashy
   fi

   if [[ ! -f $CONF ]]; then
      $(command -v mkdir) -p $FOLDER/dashy
      $(command -v rsync) $appfolder/$FILE $CONF -aqhv
      $(command -v chown) -cR 1000:1000 $FOLDER/dashy
   fi
}

appstartup
#"
