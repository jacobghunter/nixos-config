#!/bin/sh
# OpenHome Home-button patch, made re-runnable: the version OpenHome writes
# truncates systemUi.js to 0 bytes when applied twice without a reboot.
F=/usr/lib/qml/KeyFilters/systemUi.js
n=0
while grep -q " $F " /proc/mounts && [ $n -lt 10 ]; do umount "$F" || break; n=$((n+1)); done
grep -q " $F " /proc/mounts && exit 1
sed "s|com.webos.app.home|io.github.devic021.openhome|g" "$F" > /tmp/hackfilters.js.new
[ -s /tmp/hackfilters.js.new ] || exit 1
mv /tmp/hackfilters.js.new /tmp/hackfilters.js
mount --bind /tmp/hackfilters.js "$F"
restart sam
