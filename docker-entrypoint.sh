#!/bin/sh

MYUSER="ghost"
MYGID="10010"
MYUID="10010"

AutoUpgrade(){
  if [ -e /etc/alpine-release ]; then
    apk --no-cache upgrade
  elif [ -e /etc/os-release ]; then
    if /bin/grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then 
      export DEBIAN_FRONTEND=noninteractive
      /usr/bin/apt update
      /usr/bin/apt -y --no-install-recommends upgrade
      rm -rf /var/lib/apt/lists/*
  fi
}

ConfigureUser () {
  # Managing user
  if [ -n "${DOCKUID}" ]; then
    MYUID="${DOCKUID}"
  fi
  # Managing group
  if [ -n "${DOCKGID}" ]; then
    MYGID="${DOCKGID}"
  fi
  local OLDHOME
  local OLDGID
  local OLDUID
  /bin/grep -q "${MYUSER}" /etc/passwd
  if [ $? -eq 0 ]; then
    OLDUID=$(/usr/bin/id -u "${MYUSER}")
    OLDGID=$(/usr/bin/id -g "${MYUSER}")
    if [ "${DOCKUID}" != "${OLDUID}" ]; then
      OLDHOME=$(/bin/echo "~${MYUSER}")
      /usr/sbin/deluser "${MYUSER}"
      /usr/bin/logger "Deleted user ${MYUSER}"
    fi
    /bin/grep -q "${MYUSER}" /etc/group
    if [ $? -eq 0 ]; then
      local OLDGID=$(/usr/bin/id -g "${MYUSER}")
      if [ "${DOCKGID}" != "${OLDGID}" ]; then
        /usr/sbin/delgroup "${MYUSER}"
        /usr/bin/logger "Deleted group ${MYUSER}"
      fi
    fi
  fi
  /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
  /usr/sbin/adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    /usr/bin/find / -user "${OLDUID}" -exec /bin/chown ${MYUSER} {} \;
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    /usr/bin/find / -group "${OLDGID}" -exec /bin/chgrp ${MYUSER} {} \;
  fi
}

AutoUpgrade
ConfigureUser

if [ "$1" == 'ghost' ]; then
    if [ ! -d /ghost ]; then
      mkdir /ghost
    fi
    if [ -d /ghost ]; then
      chown -R "${MYUSER}":"${MYUSER}" /ghost
      chmod -R 0750 /ghost
    fi
    cd /ghost
    exec /sbin/su-exec "${MYUSER}" npm start --production
fi

exec "$@"
