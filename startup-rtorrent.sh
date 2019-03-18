#!/usr/bin/env sh

set -x

# set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=1000}

# update uids and gids
groupadd -g $RT_GID rtorrent
if [ $? != 0 ]; then
  addgroup -g $RT_GID rtorrent
fi

adduser -u $RT_UID -G rtorrent -h /home/rtorrent -D -s /bin/ash rtorrent

# arrange dirs and configs
mkdir -p /home/rtorrent/.rtorrent/downloads
mkdir -p /home/rtorrent/.rtorrent/completed
mkdir -p /home/rtorrent/.rtorrent/log
mkdir -p /home/rtorrent/.rtorrent/session
mkdir -p /home/rtorrent/.rtorrent/watch
if [ ! -e /home/rtorrent/.rtorrent/.rtorrent.rc ]; then
  cp /root/.rtorrent.rc /home/rtorrent/.rtorrent/.rtorrent.rc
fi
chown -R rtorrent:rtorrent /home/rtorrent
rm -f /home/rtorrent/.rtorrent/session/rtorrent.lock
