#!/bin/sh

addgroup -g ${GID} abc
adduser -D -G abc -u ${UID} abc

# make folders
mkdir -p /config/configs

# generate license file
[[ ! -f /config/znc.pem ]] && /usr/local/bin/znc -d /config -p

while [ ! -f "/config/znc.pem" ]; do
echo "waiting for pem file to be generated"
sleep 1s
done

# copy config
[[ ! -f /config/configs/znc.conf ]] && cp /defaults/znc.conf /config/configs/znc.conf

# permissions
chown -R abc:abc /config

chpst -u abc -U abc -- sh -c '/usr/local/bin/znc -d /config --foreground'
